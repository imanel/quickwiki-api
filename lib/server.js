(function() {
  var QuickWiki, formatResult, guessFormat, http, port, sendResponse, url;
  http = require('http');
  url = require('url');
  QuickWiki = require('./quick_wiki');
  port = process.env.PORT || 5000;
  guessFormat = function(pathname) {
    return 'json';
  };
  formatResult = function(format, result) {
    return JSON.stringify({
      result: result.type,
      data: result.data
    });
  };
  sendResponse = function(response, status, format, result) {
    response.writeHead(status, {
      "content-type": "application/json"
    });
    return response.end(formatResult(format, result));
  };
  http.createServer(function(request, response) {
    var format, path;
    path = url.parse(request.url, true);
    format = guessFormat(path.pathname);
    return QuickWiki.query(path.query.q, function(result) {
      return sendResponse(response, 200, format, result);
    });
  }).listen(port);
  console.log("Started on port " + port);
  process.on('uncaughtException', function(err) {
    return console.log(err.stack);
  });
}).call(this);
