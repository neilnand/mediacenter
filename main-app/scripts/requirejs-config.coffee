# Configure
require.config(
  config:
    text:
      useXhr: (url, protocol, hostname, port) ->
        true
  paths:
    Angular: './../components/angular/angular'
    text: './../components/requirejs-text/text'
  shim:
    Angular:
      exports: 'angular'
)

#Initialize
require([
  'Angular'
  './MainApp'
],(
  angular
  MainApp
) ->

  # Setup Project
  app = MainApp.initialize []
  MainApp.startup()

  # Dynamically adding ng-app to HTML
  angular.bootstrap window.document, [app.name]


)