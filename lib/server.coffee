http = require 'http'
url = require 'url'
QuickWiki = require './quick_wiki'
port = process.env.PORT || 5000

# Todo
guessFormat = (pathname) ->
  'json'

# Todo
formatResult = (format, result) ->
  JSON.stringify { result: result.type, data: result.data }

  # Todo
sendResponse = (response, status, format, result) ->
  response.writeHead status, {"content-type":"application/json", "Access-Control-Allow-Origin":"*"}
  response.end formatResult(format, result)

http.createServer( (request, response) ->
  path = url.parse(request.url, true)
  format = guessFormat(path.pathname)
  QuickWiki.query path.query.q, (result) ->
    sendResponse(response, 200, format, result)

).listen(port)

console.log("Started on port " + port)

# Prevent server from failing
process.on 'uncaughtException', (err) ->
  console.log(err.stack)
