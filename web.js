var http = require('http'),
    request = require('request'),
    cheerio = require("cheerio");

function do_query(query, callback) {
  request({
    method: 'GET',
    uri: 'http://en.wikipedia.org/w/index.php?title=Special:Search&search=' + encodeURI(query),
    headers: {
      'User-Agent': 'QuickWiki.info Blackberry-compatible Browser'
    }
  }, callback)
}

function parseData(content) {
  var documentBody, bodyContent, list, result;

  documentBody = cheerio.load(content),
  bodyContent = documentBody('#bodyContent');

  list = ( bodyContent.find('#disambigbox').size() > 0);

  if(list) {
    result = parseList(bodyContent);
  } else {
    result = parseText(bodyContent);
  }
  return result
}

function parseText(content) {
  var contentWrapper,contentHTML,paragraph;
  contentWrapper = content.find('.mw-content-ltr');
  contentWrapper.remove('table');
  contentHTML = contentWrapper.find('p').html();
  paragraph = cheerio.load(contentHTML);
  paragraph('sup').remove();
  return { type: 'text', data: paragraph('p').text() }
}

function parseList(content) {
  return { type: 'list', data: [] }
}

do_query('apple inc', function(error, response, body) {
  if(!error && response.statusCode == 200) {
    var result = parseData(body);
    console.log( { result: result.type, data: result.data } );
  }
});
