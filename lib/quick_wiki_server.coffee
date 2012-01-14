http = require 'http'
url = require 'url'
QuickWiki = require './quick_wiki'

QuickWikiServer =
  run: (port) ->
    server = http.createServer (request, response) =>
      path = url.parse(request.url, true)
      format = @guessFormat(path.pathname)
      if !format
        @sendResponse response, 404, 'text', { type: 'invalid', data: 'Unknown format type.' }
      else if !path.query.q
        @sendResponse response, 400, format, { type: 'invalid', data: 'No query provided.' }
      else
        QuickWiki.query path.query.q, path.query.lang, (result) =>
          status = @getStatus(result.type)
          @sendResponse(response, status, format, result)
    server.listen(port)

  guessFormat: (pathname) ->
    switch pathname
      when '/json' then 'json'
      else undefined

  formatResult: (format, result) ->
    switch format
      when 'text' then result.data
      when 'json'
        json = { result: result.type, data: result.data }
        json.url = result.url if result.url?
        JSON.stringify json

  formatHeaders: (format) ->
    base = { "Access-Control-Allow-Origin": "*" }
    base['Content-Type'] = switch format
      when 'json' then 'application/json'
      when 'text' then 'text/plain'
    base

  sendResponse: (response, status, format, result) ->
    response.writeHead status, @formatHeaders(format)
    response.end @formatResult(format, result)

  getStatus: (status) ->
    switch status
      when 'error' then 500
      when 'invalid' then 400
      else 200

module.exports = QuickWikiServer if module?
