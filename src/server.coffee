http = require 'http'
QuickWiki = require './quick_wiki'

QuickWiki.query 'apple inc', (result) ->
  console.log result
