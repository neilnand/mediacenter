(function() {
  var HttpApp, grunt, httpApp, npmPackage, requirejs;

  requirejs = require("requirejs");

  grunt = require("grunt");

  requirejs.config({
    baseUrl: __dirname,
    nodeRequire: require
  });

  HttpApp = new requirejs("./http-app/HttpApp");

  npmPackage = grunt.file.readJSON("package.json");

  httpApp = new HttpApp(__dirname, npmPackage.ports.release);

  httpApp.route("/", __dirname + "/public/index.html");

  httpApp.route("/remote", __dirname + "/public/html/remote.html");

  httpApp.listen();

}).call(this);
