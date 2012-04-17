request = require('request')
cheerio = require("cheerio")

QuickWiki =
  query: (query, lang, callback) ->
    lang ||= 'en'
    if @knownLanguages.indexOf(lang) == -1
      callback @unknownLanguage
    else
      @do_query query, lang, (error, response, body) =>
        if !error && response.statusCode == 200
          callback @parseData(body, response.request.uri.href)
        else
          callback @errorResponse

  do_query: (query, lang, callback) ->
    request {
      method: 'GET',
      uri: "http://#{lang}.wikipedia.org/w/index.php?title=Special:Search&search=" + encodeURI(query),
      headers: {
        'User-Agent': 'QuickWiki.info Browser'
      }
    }, callback

  parseData: (content, url) ->
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
        @parseText(jQuery, contentWrapper, url)

  parseText: (jQuery, content, url) ->
    result = undefined
    content.find('p').each (i, elem) ->
      parent = this.parent
      if parent.type == 'tag' && parent.name == 'div'
        result = jQuery(this)
        return false
    if result
      result.remove('sup')
      { type: 'text', data: result.text(), url: @checkURL(url) }
    else
      @missingResponse

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

  checkURL: (url) ->
    url.replace(/\/\/(\w+)\.m\.wikipedia\.org\//, "//$1.wikipedia.org/")

  missingResponse: { type: 'missing', data: 'Article not found.' }
  errorResponse: { type: 'error', data: 'Server error - please try again later.' }
  unknownLanguage: { type: 'invalid', data: 'Unknown Wikipedia language.' }

  knownLanguages: [ "ar", "bg", "ca", "cs", "da", "de", "en", "es", "eo", "eu", "fa", "fr", "ko", "hi", "hr", "id", "it", "he", "lt", "hu", "ms", "nl", "ja", "no", "pl", "pt", "kk", "ro", "ru", "sk", "sl", "sr", "fi", "sv", "tr", "uk", "vi", "vo", "war", "zh" ]

module.exports = QuickWiki if module?
