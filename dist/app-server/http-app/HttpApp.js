(function() {
  define([], function() {
    var HttpApp;
    return HttpApp = (function() {
      function HttpApp(__dirname, defaultPort) {
        var express, path;
        if (defaultPort == null) {
          defaultPort = 8080;
        }
        express = require("express");
        this.app = new express();
        this.server = require("http").createServer(this.app);
        path = require("path");
        this.app.set('port', process.env["TEST_PORT"] || defaultPort);
        this.app.use(express.favicon());
        this.app.use(express.logger('dev'));
        this.app.use(express.bodyParser());
        this.app.use(express.methodOverride());
        this.app.use(express["static"](path.join(__dirname, 'public')));
      }

      HttpApp.prototype.route = function(path, file) {
        var _this = this;
        return this.app.get(path, function(req, res) {
          return res.sendfile(file);
        });
      };

      HttpApp.prototype.listen = function() {
        var _this = this;
        return this.server.listen(this.app.get("port"), function() {
          return console.log("Express server listening on port " + _this.app.get("port"));
        });
      };

      return HttpApp;

    })();
  });

}).call(this);
