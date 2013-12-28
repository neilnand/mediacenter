######## RequireJS Setup
requirejs = require "requirejs"
grunt = require "grunt"

requirejs.config {
  baseUrl: __dirname
  nodeRequire: require
}

HttpApp = new requirejs "./http-app/HttpApp"


######## Setup App
npmPackage = grunt.file.readJSON "package.json"

httpApp = new HttpApp __dirname, npmPackage.ports.release
httpApp.route "/", __dirname + "/public/index.html"
httpApp.route "/remote", __dirname + "/public/html/remote.html"

# IO Setup
activeSocket = null
httpApp.io.sockets.on "connection", (socket) ->

  socket.emit "message", {
    message: "welcome to the chat"
  }

  socket.on "send", (data) ->
    # Emit to All
    httpApp.io.sockets.emit "message", data

  socket.on "screen", (data) ->
    socket.type = "screen"
    activeSocket = socket
    console.log "Screen ready..."

  socket.on "remote", (data) ->
    socket.type = "remote"
    console.log "Remote ready..."
    if activeSocket isnt undefined
      console.log "Synced .."





httpApp.listen()