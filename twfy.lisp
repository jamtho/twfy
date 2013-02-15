;;;; twfy.lisp

(in-package #:twfy)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Constants

(defvar *api-key* nil
  "API key (register for one at http://www.theyworkforyou.com/api/key)")

(defparameter *base-uri* "http://www.theyworkforyou.com/api/"
  "Root for all twfy api calls")

(defvar *decode-response* t
  "If set, and *output-format* is \"js\", API responses will be decoded from
json to lisp objects with cl-json.")

(defvar *output-format* "js"
  "Passed in the querystring to control the API response format; values can be
\"js\", \"xml\", \"php\", or \"rabx\".")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; API caller

(defun decode-json (str)
  "Helper for CALL-API. Decodes json string STR into symbols, using the
SIMPLIFIED-CAMEL-CASE translator."
  (let ((cl-json:*json-identifier-name-to-lisp*
         #'cl-json:simplified-camel-case-to-lisp))
    (cl-json:decode-json-from-string str)))

(defun clean-alist (alist)
  "Helper for CALL-API. Returns a copy of ALIST with all pairs having null
cdr removed, and all remaining cdr's changed to strings."
  (remove-if #'null
             (mapcar (lambda (pair)
                       (when (cdr pair)
                         (cons (car pair)
                               (format nil "~A" (cdr pair)))))
                     alist)))

(defun api-command-uri (fun)
  "Returns the URI to use for (string) command FUN."
  (concatenate 'string *base-uri* fun))

(defun call-api (fun &optional params)
  "Makes a GET call to the TWFY API, for function named string FUN, with
arbitrary query string parameters alist PARAMS. Respects *decode-response*."
  (let ((res (drakma:http-request (api-command-uri fun)
                                  :parameters
                                  (append `(("key" . ,*api-key*)
                                            ("output" . ,*output-format*))
                                          (clean-alist params)))))
    (if (stringp res)
        (if (and (equal *output-format* "js")
                 *decode-response*)
            (decode-json res)
            res)
        ;; Boundary data is always KML, and its Content-Type is treated as
        ;; binary by Drakma. We just return the xml as-is.
        ;; 
        ;; FIXME this is a fudge, as it relies on the only non-*ouput-format*-
        ;; obeying response having an unusual Content-Type.
        ;; I should override *output-format* for this, and do a 'if not a
        ;; string then make a string' conversion for all responses.
        (flexi-streams:octets-to-string res))))
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; API command definition system

(defmacro alist-builder (&rest symbols)
  "Helper for DEFINE-API-COMMAND. Creates an alist of (lower-case-symbol-
name-string . symbol-val) pairs, using each member of list SYMBOLS."
  `(list ,@(mapcar (lambda (sym)
                     `(cons (format nil "~(~A~)" ',sym)
                            ,sym))
                   symbols)))

(defmacro define-api-command (fun-name api-fun-name params-list docstring)
  "Defines a function FUN-NAME, calling API command (string) API-FUN-NAME,
taking optional parameters symbol list PARAMS-LIST, with documentation
DOCSTRING."
  `(defun ,fun-name (&key ,@params-list)
     ,docstring
     (call-api ,api-fun-name
               (alist-builder ,@params-list))))
            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Define the API commands

;;; Hansard URL conversion

(define-api-command convert-url "convertURL"
  (url)
  "Converts a parliament.uk Hansard URL into a TheyWorkForYou one, if possible.

Arguments:

- url (required)
    The parliament.uk URL you wish to convert, e.g. http://www.publications.parliament.uk/pa/cm201011/cmhansrd/cm110908/debtext/110908-0002.htm#11090852001644")


;;; Constituency

(define-api-command get-constituency "getConstituency"
  (name postcode)
  "Fetch a UK Parliament constituency.

Arguments:

- name
    Fetch the data associated to the constituency with this name.

- postcode
    Fetch the constituency with associated information for a given postcode.")

(define-api-command get-constituencies "getConstituencies"
  (date search)
  "Fetch a list of UK Parliament constituencies.

Arguments:

Note only one argument can be given at present.

- date (optional)
    Fetch the list of constituencies as on this date.

- search (optional)
    Fetch the list of constituencies that match this search string.")


;;; Person

(define-api-command get-person "getPerson"
  (id)
  "Fetch a particular person.

Arguments:

- id
    If you know the person ID for the member you want (returned from getMPs or elsewhere), this will return data for that person. This will return all database entries for this person, so will include previous elections, party changes, etc.")


;;; MPs

(define-api-command get-mp "getMP"
  (id constituency postcode always_return)
  "Fetch a particular MP.

Arguments:

- postcode (optional)
    Fetch the MP for a particular postcode (either the current one, or the most recent one, depending upon the setting of the always_return variable. This will only return their current/ most recent entry in the database, look up by ID to get full history of a person. 

- constituency (optional)
    The name of a constituency; we will try and work it out from whatever you give us. :) This will only return their current/ most recent entry in the database, look up by ID to get full history of a person. 

- id (optional)
    If you know the person ID for the member you want (returned from getMPs or elsewhere), this will return data for that person. This will return all database entries for this person, so will include previous elections, party changes, etc.

- always_return (optional)
    For the postcode and constituency options, sets whether to always try and return an MP, even if the seat is currently vacant (due to e.g. the death of an MP, or the period before an election when there are no MPs).")

(define-api-command get-mp-info "getMPInfo"
  (id fields)
  "Fetch extra information for a particular person.

Arguments:

- id
    The person ID.

- fields (optional)
    Which fields you want to return, comma separated (leave blank for all).")

(define-api-command get-mps "getMPs"
  (date party search)
  "Fetch a list of MPs.

Note that during the period before a general election when there are no MPs, this call will correctly return no results for a default (today) lookup.

Arguments:

- date (optional)
    Fetch the list of MPs as it was on this date.

- party (optional)
    Fetch the list of MPs from the given party.

- search (optional)
    Fetch the list of MPs that match this search string in their name. ")

;; NB bug in official documentation, I think; it says 'ids', which isn't accepted.
(define-api-command get-mps-info "getMPsInfo"
  (id fields)
  "Fetch extra information for particular people.

Arguments:

- id
    The person IDs, separated by commas.

- fields (optional)
    Which fields you want to return, comma separated (leave blank for all).")


;;; Lords

(define-api-command get-lord "getLord"
  (id)
  "Fetch a particular Lord.

Arguments:

- id (optional)
    If you know the person ID for the Lord you want, this will return data for that person. ")

(define-api-command get-lords "getLords"
  (date party search)
  "Fetch a list of Lords.

Arguments:

- date (optional)
    Fetch the list of Lords as it was on this date. Note our from date is when the Lord is introduced in Parliament.

- party (optional)
    Fetch the list of Lords from the given party.

- search (optional)
    Fetch the list of Lords that match this search string in their name.")


;;; MLAs

(define-api-command get-mla "getMLA"
  (postcode constituency id)
  "Fetch a particular MLA.

Arguments:

- postcode (optional)
    Fetch the MLAs for a particular postcode.

- constituency (optional)
    The name of a constituency.

- id (optional)
    If you know the person ID for the member you want (returned from getMLAs or elsewhere), this will return data for that person.")

(define-api-command get-mlas "getMLAs"
  (date party search)
  "Fetch a list of MLAs.

Arguments:

- date (optional)
    Fetch the list of MLAs as it was on this date.

- party (optional)
    Fetch the list of MLAs from the given party.

- search (optional)
    Fetch the list of MLAs that match this search string in their name.")


;;; MSPs

(define-api-command get-msp "getMSP"
  (postcode constituency id)
  "Fetch a particular MSP.

Arguments:

- postcode (optional)
    Fetch the MSPs for a particular postcode.

- constituency (optional)
    The name of a constituency.

- id (optional)
    If you know the person ID for the member you want (returned from getMSPs or elsewhere), this will return data for that person.")

(define-api-command get-msps "getMSPs"
  (date party search)
  "Fetch a list of MSPs.

Arguments:

- date (optional)
    Fetch the list of MSPs as it was on this date.

- party (optional)
    Fetch the list of MSPs from the given party.

- search (optional)
    Fetch the list of MSPs that match this search string in their name.")


;;; Constituencies

(define-api-command get-geometry "getGeometry"
  (name)
  "Returns geometry information for constituencies.

This currently includes, for Great Britain, the latitude and longitude of the centre point of the bounding box of the constituency, its area in square metres, the bounding box itself and the number of parts in the polygon that makes up the constituency. For Northern Ireland, as we don't have any better data, it only returns an approximate (estimated by eye) latitude and longitude for the constituency's centroid.

Arguments:

- name
    Name of the constituency.")

(define-api-command get-boundary "getBoundary"
  (name)
  "getBoundary function

http://www.theyworkforyou.com/api/getBoundary

Returns KML file for a UK Parliament constituency.

Returns the bounding polygon of the constituency, in KML format (see mapit.mysociety.org for other formats, past constituency boundaries, and so on).

Arguments:

- name
    Name of the constituency.")


;;; Committees

(define-api-command get-committee "getCommittee"
  (name date)
  "Fetch the members of a Select Committee.

We have no information since the 2010 general election, and information before may be inaccurate.

Arguments:

- name (optional)
    Fetch the members of the committee that match this name - if more than one committee matches, return their names. If left blank, return all committee names for the date provided (or current date) in the database.

- date (optional)
    Return the members of the committee as they were on this date.")


;;; Documents

(define-api-command get-debates "getDebates"
  (type date search person gid order page num)
  "Fetch Debates.

This includes Oral Questions.

Arguments:

Note you can only supply one of the following search terms at present.

- type (required)
    One of \"commons\", \"westminsterhall\", \"lords\", \"scotland\", or \"northernireland\".

- date
    Fetch the debates for this date.

- search
    Fetch the debates that contain this term.

- person
    Fetch the debates by a particular person ID.

- gid
    Fetch the speech or debate that matches this GID.

- order (optional, when using search or person)
    d for date ordering, r for relevance ordering.

- page (optional, when using search or person)
    Page of results to return.

- num (optional, when using search or person)
    Number of results to return.")

(define-api-command get-wrans "getWrans"
  (date search person gid order page num)
  "Fetch Written Questions/Answers.

Arguments:

Note you can only supply one of the following at present.

- date
    Fetch the written answers for this date.

- search
    Fetch the written answers that contain this term.

- person
    Fetch the written answers by a particular person ID.

- gid
    Fetch the written question/answer that matches this GID.

- order (optional, when using search or person)
    d for date ordering, r for relevance ordering.

- page (optional, when using search or person)
    Page of results to return.

- num (optional, when using search or person)
    Number of results to return.")

(define-api-command get-wms "getWMS"
  (date search person gid order page num)
  "Fetch Written Ministerial Statements.

Arguments:

Note you can only supply one of the following at present.

- date
    Fetch the written ministerial statements for this date.

- search
    Fetch the written ministerial statements that contain this term.

- person
    Fetch the written ministerial statements by a particular person ID.

- gid
    Fetch the written ministerial statement(s) that matches this GID.

- order (optional, when using search or person)
    d for date ordering, r for relevance ordering.

- page (optional, when using search or person)
    Page of results to return.

- num (optional, when using search or person)
    Number of results to return.")

(define-api-command get-hansard "getHansard"
  (search person order page num)
  "Fetch all Hansard.

Arguments:

Note you can only supply one of the following at present.

- search
    Fetch the data that contain this term.

- person
    Fetch the data by a particular person ID.

- order (optional, when using search or person, defaults to date)
    d for date ordering, r for relevance ordering, p for use by person.

- page (optional, when using search or person)
    Page of results to return.

- num (optional, when using search or person)
    Number of results to return.")


;;; TWFY comments

(define-api-command get-comments "getComments"
  (start_date end_date search pid page num)
  "Fetch comments left on TheyWorkForYou.

With no arguments, returns most recent comments in reverse date order.

Arguments:

- start_date, end_date (optional)
    Fetch the comments between two dates (inclusive).

- search (optional)
    Fetch the comments that contain this term.

- pid
    Fetch the comments made on a particular person ID (MP/Lord).

- page (optional)
    Page of results to return.

- num (optional)
    Number of results to return.")
