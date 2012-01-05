(function() {
  var QuickWiki, http;
  http = require('http');
  QuickWiki = require('./quick_wiki');
  QuickWiki.query('apple inc', function(result) {
    return console.log(result);
  });
}).call(this);
