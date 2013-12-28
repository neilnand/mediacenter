# Configure
require.config(
  config:
    text:
      useXhr: (url, protocol, hostname, port) ->
        true
  paths:
    socketio: './../components/socket.io-client/dist/socket.io.min'
    Angular: './../components/angular/angular'
    text: './../components/requirejs-text/text'
  shim:
    Angular:
      exports: 'angular'
    socketio:
      exports: 'io'
)

#Initialize
require([
  'Angular'
  'socketio'
  './MainApp'
],(
  angular
  io
  MainApp
) ->

  # Setup Project
  app = MainApp.initialize []
  MainApp.startup()

  # Dynamically adding ng-app to HTML
  angular.bootstrap window.document, [app.name]


)