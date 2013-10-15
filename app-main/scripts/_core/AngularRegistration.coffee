define([], () ->

  ###*
  # The registration and initialization process
  #
  # @class AngularRegistration
  # @constructor
  # @param {AngularModule} @app Angular Module to register directives, filters and services
  ###

  class AngularRegistration
    register: (app, map, initFunc, lowerCaseFirst = true) ->
      for name, component of map
        app[initFunc](@parseName(name, lowerCaseFirst), component)
        console.log "##     •", initFunc, @parseName(name, lowerCaseFirst)
    parseName: (val, lowerCaseFirst) ->
      if lowerCaseFirst and val
        val.slice(0, 1).toLowerCase() + val.slice(1, val.length)
      else
        val

  # Return
  new AngularRegistration()

)