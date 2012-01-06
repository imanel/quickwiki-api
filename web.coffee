QuickWikiServer = require './lib/quick_wiki_server'
port = process.env.PORT || 5000

QuickWikiServer.run port
console.log "Started on port " + port

# Prevent server from failing
process.on 'uncaughtException', (err) ->
  console.log(err.stack)
