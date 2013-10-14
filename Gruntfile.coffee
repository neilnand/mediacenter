module.exports = (grunt) ->

  # Libs
  _ = require "underscore"

  # Settings
  TASK_DIR = "./tasks/"
  BUILD_DIR = "./tmp/"
  RELEASE_DIR = "./dist/"

  TASKS = {
    default: [
      "coffeelint"
      "clean"
      "coffee"
      "symlink"
    ]
    clear: [
      "clean"
    ]
    release: [
      "coffeelint"
      "clean"
      "coffee"
      "uglify"
      "symlink"
      "requirejs"
    ]
  }

  npmPackage = grunt.file.readJSON "package.json"

  projects =
    main:
      id: "main-app"
      name: "MainApp"
      config: "requirejs-config.js"
      outputFilename: "main-app.js"
      exludeDep: [
        "Angular"
      ]
    server:
      id: "server-app"
      outputFilename: "server-app.js"

  # Configuration
  grunt.initConfig
    name: npmPackage.name

    # Ensure we're using good coding standards
    coffeelint:
      app: [
        "#{projects.main.id}/**/*.coffee"
        "#{projects.server.id}/**/*.coffee"
      ]
      options:
        max_line_length:
          value: 120

    # Delete output directories
    clean: [
      BUILD_DIR
      RELEASE_DIR
    ]

    # Convert CoffeeScript into JavaScript
    coffee:
      main:
        expand: true,
        cwd: "#{projects.main.id}/scripts"
        src: "**/*.coffee"
        dest: "#{BUILD_DIR}/#{projects.main.id}/scripts"
        ext: ".js"
      server:
        expand: true,
        cwd: "#{projects.server.id}"
        src: "**/*.coffee"
        dest: "#{BUILD_DIR}/#{projects.server.id}/"
        ext: ".js"

    # Uglify and minificate server-app
    uglify:
      options:
        mangle: true
        banner: "/*! <%= name %> <%= grunt.template.today('yyyy-mm-dd') %> */\n"
      server:
        src: "#{BUILD_DIR}/#{projects.server.id}/**/*"
        dest: [
          RELEASE_DIR
          projects.server.id
          projects.server.outputFilename
        ].join("/")

    # Create reference shortcuts
    symlink:
      components:
        dest: "#{BUILD_DIR}/#{projects.main.id}/components"
        relativeSrc: "./../../bower_components/"
        options:
          type: "dir"

    # Compile RequireJS structure
    requirejs:
      compile:
        options:
          name: projects.main.name
          baseUrl: "#{BUILD_DIR}/#{projects.main.id}/scripts"
          mainConfigFile: "#{BUILD_DIR}/#{projects.main.id}/scripts/#{projects.main.config}"
          exclude: projects.main.exludeDep
          include: [projects.main.config]
          out: [
            RELEASE_DIR
            projects.main.id
            projects.main.outputFilename
          ].join("/")


  # Load NPM modules
  matchdep = require "matchdep"
  matchdep.filterDev("grunt-*").forEach(grunt.loadNpmTasks)

  # Register Tasks
  for taskName, taskList of TASKS
    grunt.registerTask taskName, taskList