request = require('request')
cheerio = require("cheerio")

QuickWiki =
  query: (query, collback) ->
    @do_query query, (error, response, body) =>
      if !error && response.statusCode == 200
        collback @parseData(body)

  do_query: (query, callback) ->
    request {
      method: 'GET',
      uri: 'http://en.wikipedia.org/w/index.php?title=Special:Search&search=' + encodeURI(query),
      headers: {
        'User-Agent': 'QuickWiki.info Blackberry-compatible Browser'
      }
    }, callback

  parseData: (content) ->
    documentBody = cheerio.load(content)
    bodyContent = documentBody('#bodyContent')

    list = bodyContent.find('#disambigbox').size() > 0

    if list
      @parseList(bodyContent)
    else
      @parseText(bodyContent)

  parseText: (content) ->
    contentWrapper = content.find('.mw-content-ltr')
    contentWrapper.remove('table')
    contentHTML = contentWrapper.find('p').html()
    paragraph = cheerio.load(contentHTML)
    paragraph('sup').remove()
    { type: 'text', data: paragraph('p').text() }

  parseList: (content) ->
    { type: 'list', data: [] }

module.exports = QuickWiki if module?
