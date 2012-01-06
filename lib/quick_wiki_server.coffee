http = require 'http'
url = require 'url'
QuickWiki = require './quick_wiki'

QuickWikiServer =
  run: (port) ->
    server = http.createServer (request, response) =>
      path = url.parse(request.url, true)
      format = @guessFormat(path.pathname)
      QuickWiki.query path.query.q, (result) =>
        @sendResponse(response, 200, format, result)
    server.listen(port)

  guessFormat: (pathname) ->
    'json'

  # Todo
  formatResult: (format, result) ->
    JSON.stringify { result: result.type, data: result.data }

  formatHeaders: (format) ->
    base = { "Access-Control-Allow-Origin": "*" }
    base['Content-Type'] = "application/json"

  # Todo
  sendResponse: (response, status, format, result) ->
    response.writeHead status, @formatHeaders(format)
    response.end @formatResult(format, result)

module.exports = QuickWikiServer if module?
