# HTTP

### httpserver.lua

Simple http server implementation that allows the registration of 'handlers' for incomming HTTP requests.

Example useage:

    http = dofile("httpserver.lua")() -- Init, opens port 80 and listens for incomming HTTP

Example of a 'handler' function which receives the request as a param and can decide to handle it or not.

    http:addHandler(myHandler)

`addHandler` definition: `http.addHandler(function(req))`

Handler function definition: `function(req)`:

 - @req param (table)
  - @req.method (sting)
  - @req.url (table) (array style)
  - @req.headers (table) (dictionary style)
  - @req.body (string)

Handler function must return:

 - `false` Don't handle request, request will be passed on the next handler
 - `true, respTable` Handle the request, response is based on second return value
	 - Second return value is table which contains:
		 - status (string)
		 - body (string)
		 - header (table) (dictionary style)

Example handler:

	function myHandler(req)
		if req.method == "GET" and req.url[1] == "index" and req.headers["Accept"] == "text/plain" then
			return true, { status = "200 OK", body = "Hi from 'index' page", headers = { ["Content-Type"] = "text/plain" } }
		end
		return false
    end

