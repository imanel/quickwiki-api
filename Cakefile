{exec} = require 'child_process'

task 'build', 'build source', ->
  exec 'coffee -c -o lib/ src/*.coffee'

task 'watch', 'build and watch source', ->
  exec 'coffee -w -c -o lib/ src/*.coffee'