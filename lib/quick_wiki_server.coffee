http = require 'http'
url = require 'url'
QuickWiki = require './quick_wiki'

QuickWikiServer =
  run: (port) ->
    server = http.createServer (request, response) =>
      path = url.parse(request.url, true)
      format = @guessFormat(path.pathname)
      if !format
        @sendResponse response, 404, 'text', { result: 'error', data: 'Unknown format type.'}
      else
        QuickWiki.query path.query.q, (result) =>
          @sendResponse(response, 200, format, result)
    server.listen(port)

  guessFormat: (pathname) ->
    switch pathname
      when '/json' then 'json'
      else undefined

  formatResult: (format, result) ->
    switch format
      when 'json' then JSON.stringify { result: result.type, data: result.data }
      when 'text' then result.data

  formatHeaders: (format) ->
    base = { "Access-Control-Allow-Origin": "*" }
    base['Content-Type'] = switch format
      when 'json' then 'application/json'
      when 'text' then 'text/plain'
    base

  sendResponse: (response, status, format, result) ->
    response.writeHead status, @formatHeaders(format)
    response.end @formatResult(format, result)

module.exports = QuickWikiServer if module?
