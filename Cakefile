fs = require 'fs'
path = require 'path'
{print} = require 'util'
{spawn, exec} = require 'child_process'

option '-w', '--watch', 'Recompile CoffeeScript source file when modified'
option '-m', '--minify', 'Minify compiled script'

task 'build', 'Compile CoffeeScript source file', (options) ->
  opt = ['-c', '-o', 'lib', 'src']
  opt.unshift '-w' if options.watch

  coffee = spawn (path.resolve 'node_modules', '.bin', 'coffee'), opt
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()

  coffee.on 'exit', (status) ->
    unless fs.existsSync path.resolve 'dest'
      fs.mkdirSync path.resolve 'dest'
    for js in fs.readdirSync path.resolve 'lib'
      if (path.extname js) is '.js'
        src = path.resolve 'lib', js
        dst = path.resolve 'dest', "#{js.replace /\.js$/, ''}.min.js"
        do (js) ->
          minify = spawn (path.resolve 'node_modules', 'minify', 'bin', 'minify'), [src, dst]
          minify.stdout.on 'data', (data) -> print data.toString()
          minify.stderr.on 'data', (data) -> print data.toString()
