var http = require('http'),
    request = require('request'),
    cheerio = require("cheerio");

function do_query(query, callback) {
  request({
    method: 'GET',
    uri: 'http://en.wikipedia.org/w/index.php?title=Special:Search&search=' + encodeURI(query),
    headers: {
      'User-Agent': 'QuickWiki.info Browser'
    }
  }, callback)
}

do_query('apple inc', function(error, response, body) {
  if(!error && response.statusCode == 200) {
    var $ = cheerio.load(body);
    var bodyContent = $('#bodyContent');
    var list = ( bodyContent.find('#disambigbox').size() == 0);
    var content_wrapper = bodyContent.find('.mw-content-ltr');
    content_wrapper.remove('table');
    var content_html = content_wrapper.find('p').html();
    var content = cheerio.load(content_html);
    content('sup').remove();
    console.log( content('p').text() );
  }
});
