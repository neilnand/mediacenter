# RequireJS Setup
requirejs = require "requirejs"
grunt = require "grunt"

requirejs.config {
  nodeRequire: require
}

HttpApp = new requirejs "./http-app/HttpApp"


# Setup App
npmPackage = grunt.file.readJSON "package.json"

httpApp = new HttpApp __dirname, npmPackage.ports.release
httpApp.route "/", __dirname + "/public/index.html"
httpApp.route "/remote", __dirname + "/public/html/remote.html"

httpApp.listen()