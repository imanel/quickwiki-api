(function() {
  var QuickWiki, cheerio, request;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  request = require('request');
  cheerio = require("cheerio");
  QuickWiki = {
    query: function(query, collback) {
      return this.do_query(query, __bind(function(error, response, body) {
        if (!error && response.statusCode === 200) {
          return collback(this.parseData(body));
        }
      }, this));
    },
    do_query: function(query, callback) {
      return request({
        method: 'GET',
        uri: 'http://en.wikipedia.org/w/index.php?title=Special:Search&search=' + encodeURI(query),
        headers: {
          'User-Agent': 'QuickWiki.info Blackberry-compatible Browser'
        }
      }, callback);
    },
    parseData: function(content) {
      var bodyContent, documentBody, list;
      documentBody = cheerio.load(content);
      bodyContent = documentBody('#bodyContent');
      list = bodyContent.find('#disambigbox').size() > 0;
      if (list) {
        return this.parseList(bodyContent);
      } else {
        return this.parseText(bodyContent);
      }
    },
    parseText: function(content) {
      var contentHTML, contentWrapper, paragraph;
      contentWrapper = content.find('.mw-content-ltr');
      contentWrapper.remove('table');
      contentHTML = contentWrapper.find('p').html();
      paragraph = cheerio.load(contentHTML);
      paragraph('sup').remove();
      return {
        type: 'text',
        data: paragraph('p').text()
      };
    },
    parseList: function(content) {
      return {
        type: 'list',
        data: []
      };
    }
  };
  if (typeof module !== "undefined" && module !== null) {
    module.exports = QuickWiki;
  }
}).call(this);
