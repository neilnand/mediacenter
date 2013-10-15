module.exports = (grunt) ->

  # Libs
  _ = require "underscore"

  # Settings
  TASK_DIR = "./tasks/"
  BUILD_DIR = "./tmp/"
  RELEASE_DIR = "./dist/"

  BANNER_OUTPUT = "/*! <%= name %> <%= grunt.template.today('yyyy-mm-dd') %> */\n"

  TASKS = {
    default: [
      "coffeelint"
      "clean:builds"
      "coffee"
      "copy:build"
      "symlink"
      "compass:build"
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
      "compass:release"
      "copy:release"
      "yuidoc"
    ]
    docs: [
      "clean"
      "yuidoc"
    ]
  }

  npmPackage = grunt.file.readJSON "package.json"

  projects =
    main:
      id: "app-main"
      docs: "docs-main"
      name: "MainApp"
      config: "requirejs-config.js"
      outputFilename: "main-app.js"
      inputStyle: "main.sass"
      exludeDep: [
        "Angular"
      ]
    server:
      id: "app-server"
      docs: "docs-server"
      outputFilename: "server-app.js"

  # Configuration
  grunt.initConfig
    name: npmPackage.name

    # Ensure we're using good coding standards
    coffeelint:
      app: [
        projects.main.id + "/**/*.coffee"
        projects.server.id + "/**/*.coffee"
      ]
      options:
        max_line_length:
          value: 120

    # Delete output directories
    clean:
      builds: [
        BUILD_DIR
        RELEASE_DIR + projects.main.id
        RELEASE_DIR + projects.server.id
      ]
      documentation: [
        RELEASE_DIR + projects.main.docs
        RELEASE_DIR + projects.server.docs
      ]

    # Convert SASS into CSS
    compass:
      build:
        options:
          banner: BANNER_OUTPUT
          specify: projects.main.id + "/style/" + projects.main.inputStyle
          sassDir: projects.main.id + "/style/"
          cssDir: BUILD_DIR + projects.main.id + "/style/"
          environment: "development"
      release:
        options:
          banner: BANNER_OUTPUT
          specify: projects.main.id + "/style/" + projects.main.inputStyle
          sassDir: projects.main.id + "/style/"
          cssDir: RELEASE_DIR + projects.main.id + "/style/"
          outputStyle: "compressed"
          environment: "production"

    # Copy HTML and resource dependancies to working directories
    copy:
      build:
        files: [
          {
            expand: true
            cwd: projects.main.id
            src: [
              "**/*.html"
            ]
            dest: BUILD_DIR + projects.main.id
            filter: 'isFile'
          }
          {
            expand: true
            cwd: projects.server.id
            src: [
              "**/*.html"
            ]
            dest: BUILD_DIR + projects.server.id
            filter: 'isFile'
          }
        ]
      release:
        files: [
          {
            expand: true
            cwd: projects.main.id
            src: [
              "**/*.html"
            ]
            dest: RELEASE_DIR + projects.main.id
            filter: 'isFile'
          }
          {
            expand: true
            cwd: projects.server.id
            src: [
              "**/*.html"
            ]
            dest: RELEASE_DIR + projects.server.id
            filter: 'isFile'
          }
          {
            expand: true
            cwd: "./bower_components/"
            src: [
              "*/*.js"
            ]
            dest: RELEASE_DIR + projects.main.id + "/components"
            filter: 'isFile'
          }
        ]

    # Convert CoffeeScript into JavaScript
    coffee:
      main:
        expand: true,
        cwd: projects.main.id + "/scripts"
        src: "**/*.coffee"
        dest: BUILD_DIR + projects.main.id + "/scripts"
        ext: ".js"
      server:
        expand: true,
        cwd: projects.server.id
        src: "**/*.coffee"
        dest: BUILD_DIR + projects.server.id
        ext: ".js"

    # Uglify and minificate server-app
    uglify:
      options:
        mangle: true
        banner: BANNER_OUTPUT
      server:
        src: BUILD_DIR + projects.server.id + "**/*"
        dest: [
          RELEASE_DIR
          projects.server.id
          projects.server.outputFilename
        ].join("/")

    # Create reference shortcuts
    symlink:
      components:
        dest: BUILD_DIR + projects.main.id + "/components"
        relativeSrc: "./../../bower_components/"
        options:
          type: "dir"

    # Compile RequireJS main-app structure
    requirejs:
      compile:
        options:
          name: projects.main.name
          baseUrl: BUILD_DIR + projects.main.id + "/scripts"
          mainConfigFile: BUILD_DIR + projects.main.id + "/scripts/" + projects.main.config
          exclude: projects.main.exludeDep
          include: [projects.main.config]
          out: [
            RELEASE_DIR
            projects.main.id
            "/scripts/"
            projects.main.outputFilename
          ].join("/")

    # Creates documentation based on inline comments in CoffeeScript
    yuidoc:
      main:
        name: npmPackage.name
        description: npmPackage.description
        version: npmPackage.version
        url: npmPackage.homepage
        options:
          paths: projects.main.id
          outdir: RELEASE_DIR + projects.main.docs
          extension: ".coffee"
          syntaxtype: "coffee"
      server:
        name: npmPackage.name
        description: npmPackage.description
        version: npmPackage.version
        url: npmPackage.homepage
        options:
          paths: projects.server.id
          outdir: RELEASE_DIR + projects.server.docs
          extension: ".coffee"
          syntaxtype: "coffee"



  # Load NPM modules
  matchdep = require "matchdep"
  matchdep.filterDev("grunt-*").forEach(grunt.loadNpmTasks)

  # Register Tasks
  for taskName, taskList of TASKS
    grunt.registerTask taskName, taskList