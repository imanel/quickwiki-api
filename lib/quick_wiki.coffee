request = require('request')
cheerio = require("cheerio")

QuickWiki =
  query: (query, collback) ->
    @do_query query, (error, response, body) =>
      if !error && response.statusCode == 200
        collback @parseData(body)
      else
        collback @errorResponse

  do_query: (query, callback) ->
    request {
      method: 'GET',
      uri: 'http://en.wikipedia.org/w/index.php?title=Special:Search&search=' + encodeURI(query),
      headers: {
        'User-Agent': 'QuickWiki.info Blackberry-compatible Browser'
      }
    }, callback

  parseData: (content) ->
    jQuery = cheerio.load(content)
    bodyContent = jQuery('#bodyContent')

    search = bodyContent.find('#search').size() > 0

    if search
      @missingResponse
    else
      contentWrapper = bodyContent.find('.mw-content-ltr')
      list = bodyContent.find('#disambigbox').size() > 0

      if list
        @parseList(jQuery, contentWrapper)
      else
        @parseText(jQuery, contentWrapper)

  parseText: (jQuery, content) ->
    result = undefined
    content.find('p').each (i, elem) ->
      parent = this.parent
      if parent.type == 'tag' && parent.name == 'div'
        result = jQuery(this)
        return false
    if result
      result.remove('sup')
      { type: 'text', data: result.text() }
    else
      missingResponse

  parseList: (jQuery, content) ->
    result = []
    liList = []
    content.find('ul').each (i, elem) ->
      parent = this.parent
      if parent.type == 'tag' && parent.name == 'div'
        jQuery(this).find('li').each ->
          liList.push jQuery(this)
    for li in liList
      children = li.children()
      if children.size() == 1 && (link = children.find('a')).size() == 1
        result.push { link: link[0].attribs.title, text: li.text() }
    { type: 'list', data: result }

  missingResponse: { type: 'missing', data: 'Article not found.' }
  errorResponse: { type: 'error', data: 'Server error - please try again later.' }

module.exports = QuickWiki if module?
