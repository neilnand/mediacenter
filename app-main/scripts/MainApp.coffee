define([
  "Angular"
  "_core/AngularRegistration"
  "_core/directives/_reg"
  "_core/filters/_reg"
  "_core/services/_reg"
  "directives/_reg"
  "filters/_reg"
  "services/_reg"
], (
  angular
  reg
  _directivesMap
  _filtersMap
  _servicesMap
  directivesMap
  filtersMap
  servicesMap
) ->

  # Info
  CORE_APP = "Core"
  APP_NAME = "MainApp"

  ###*
  # The initialization process
  #
  # @class MainApp
  # @constructor
  # @param {AngularModule} @app Angular Module to register directives, filters and services
  ###

  class MainApp
    name: APP_NAME
    ###*
    # Wire in Angular components and initializes the project
    #
    # @method initialize
    ###
    initialize: (deps = []) =>

      # Initialize Once
      return if @isInit
      @isInit = true

      # Create Core App
      core = angular.module CORE_APP, []
      console.log "#### APP:", CORE_APP, "initialize"
      reg.register core, _directivesMap, "directive"
      reg.register core, _filtersMap, "filter"
      reg.register core, _servicesMap, "factory", false

      # Create Main App
      deps.unshift CORE_APP

      app = angular.module(APP_NAME, deps)
      console.log "#### APP:", APP_NAME, "initialize"
      reg.register app, directivesMap, "directive"
      reg.register app, filtersMap, "filter"
      reg.register app, servicesMap, "factory", false

      # Return
      app
    ###*
    # Start up the application
    #
    # @method initialize
    ###
    startup: =>
      @app.run([
        '$http'
        (
          $http
        ) ->
          # AngularJS setting to work with CORS
          delete $http.defaults.headers.common['X-Requested-With']

          console.log "project start up complete"
      ])


  # Return
  new MainApp()

)