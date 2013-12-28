define([], () ->

  class HttpApp
    constructor: (__dirname, defaultPort = 8080) ->
      # Setup
      express = require "express"
      @app = new express()
      @server = require("http").createServer(@app)
      path = require "path"
      @io = require("socket.io").listen(@server)
      spawn = require("child_process").spawn

      # Environments
      @app.set('port', process.env["TEST_PORT"] || defaultPort)
      @app.use(express.favicon())
      @app.use(express.logger('dev'))
      @app.use(express.bodyParser())
      @app.use(express.methodOverride())
      @app.use(express.static(path.join(__dirname, 'public')))

      @io.set 'log level', 1

    route: (path, file) ->
      @app.get path, (req, res) =>
        res.sendfile file

    listen: ->
      @server.listen @app.get("port"), =>
        console.log "Express server listening on port " + @app.get("port")

)