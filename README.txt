TheyWorkForYou - Common Lisp bindings
=====================================

Common Lisp bindings for the TheyWorkForYou API (UK political data).

These are really just for my use at the moment, so have some rough edges.
I've noticed a couple of text encoding screw-ups, though some of these seem
to come from the server.

Official API docs are here: http://www.theyworkforyou.com/api/

System depends on:
- Drakma
- CL-JSON


Basic usage
-----------

Each API command has a corresponding exported function, taking as keyword
parameters the API command's querystring parameters. The name mapping is
pretty obvious: getMP -> get-mp, getMPsInfo -> get-mps-info, etc.

Note that some arguments are required by the API, but the code here doesn't
force their inclusion, so the first error is seen in the API response.
TODO: raise an error locally, and don't send the request.

Set *API-KEY* to your personal key before making requests - you can
register for one here: http://www.theyworkforyou.com/api/key.


Output formats
--------------

TWFY lets you request output in a variety of formats: js, xml, php, rabx.
Change *OUTPUT-FORMAT* (string) to set this. By default you just get a
string containing the response, however...

If set to "js" (the default), setting *DECODE-RESPONSE* to non-null (T by
default) will have the response parsed to native Lisp structures with CL-JSON.
Symbol naming is done with CL-JSON:SIMPLIFIED-CAMEL-CASE-TO-LISP.
TODO: similar parsing for xml.

None of this applies to the function GET-BOUNDARY, which always returns kml
as a string.


Documentation
-------------

The raw _Web_ documentation is stored in these functions' docstrings. As said
above, there's a direct correspondence between API and keyword params, so
it's perfectly usable.

Docs source: http://www.theyworkforyou.com/api/ (again).


Dates
-----

Currently, all dates have to be expressed as a string, as are parsed on the
server: "YYYY-MM-DD" seems the right way.
TODO: Come up with a better system.


Example session
---------------

(ql:quickload 'twfy)
(setq twfy:*api-key* "xxxxx")

(twfy:get-mps :search "cameron")

-> (((:MEMBER_ID . "40665") (:PERSON_ID . "10777") (:NAME . "David Cameron")
     (:PARTY . "Conservative") (:CONSTITUENCY . "Witney")
     (:OFFICE
      ((:DEPT . "") (:POSITION . "Prime Minister") (:FROM_DATE . "2010-05-11")
       (:TO_DATE . "9999-12-31")))))

	   
Thanks
------

Obviously thanks to mySociety for building and running TheyWorkForYou, which
is great.

Also to Andrew Baxter (rhinocratic) for writing Clojure bindings; doubtless
reading his first made the job of writing these much easier.

