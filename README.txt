TheyWorkForYou - Common Lisp bindings
=====================================

Common Lisp bindings for the TheyWorkForYou API (UK political data).

These are really just for my use at the moment, so have a few rough edges.

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

Obviously thanks to mySociety for building and running TheyWorkForYou
(source: https://github.com/mysociety/theyworkforyou), which is great.

Also to Andrew Baxter (rhinocratic) for writing Clojure bindings; doubtless
reading his first made the job of writing these much easier.


License
-------

All code is under the MIT license.

The API documentation inside calls to DEFINE-API-COMMAND is derived from
TheyWorkForYou code, which is licensed under the following terms:

  Copyright (c) 2003-2004, FaxYourMP Ltd where not otherwise marked
  Copyright (c) 2003-2004, various as marked in individual files
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  * Neither the name of FaxYourMP Ltd nor the names of its contributors nor
  the name TheyWorkForYou may be used to endorse or promote products derived from
  this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

