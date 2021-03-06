module.exports = (grunt) ->

  # Libs
  _ = require "underscore"

  # Settings
  BUILD_DIR = "./tmp/"
  RELEASE_DIR = "./dist/"
  SCRIPTS_DIR = "/scripts/"
  STYLE_DIR = "/style/"
  HTML_DIR = "/html"

  BANNER_OUTPUT = "/*! <%= name %> <%= grunt.template.today('yyyy-mm-dd') %> */\n"

  TASKS = {
    default: [
      "coffeelint"
      "clean:builds"
      "coffee"
      "copy:devMain"
      "copy:devServer"
      "symlink:components"
      "symlink:main"
      "symlink:html"
      "symlink:build_public"
      "compass:dev"
#      "connect"
#      "watch"
    ]
    server: [
      "coffeelint:server"
      "clean:builds"
      "coffee:server"
      "copy:devServer"
    ]
    clear: [
      "clean"
    ]
    release: [
      "coffeelint"
      "clean"
      "coffee"
      "symlink:components"
      "requirejs"
      "compass:release"
      "copy:release"
      "symlink:release_public"
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
      public: "public"
      docs: "docs-server"
      outputFilename: "server-app.js"

  # Configuration
  grunt.initConfig
    name: npmPackage.name

    # Ensure we're using good coding standards
    coffeelint:
      main: [
        projects.main.id + "/**/*.coffee"
      ]
      server: [
        projects.server.id + "/**/*.coffee"
      ]
      options:
        max_line_length:
          value: 120

    # Delete output directories
    clean:
      builds: [
        BUILD_DIR
      ]
      release: [
        RELEASE_DIR + projects.main.id
        RELEASE_DIR + projects.server.id
      ]
      documentation: [
        RELEASE_DIR + projects.main.docs
        RELEASE_DIR + projects.server.docs
      ]

    # Convert SASS into CSS
    compass:
      dev:
        options:
          banner: BANNER_OUTPUT
          specify: projects.main.id + STYLE_DIR + projects.main.inputStyle
          sassDir: projects.main.id + STYLE_DIR
          cssDir: BUILD_DIR + projects.main.id + STYLE_DIR
          environment: "development"
      release:
        options:
          banner: BANNER_OUTPUT
          specify: projects.main.id + STYLE_DIR + projects.main.inputStyle
          sassDir: projects.main.id + STYLE_DIR
          cssDir: RELEASE_DIR + projects.main.id + STYLE_DIR
          outputStyle: "compressed"
          environment: "production"

    # Copy HTML and resource dependancies to working directories
    copy:
      devMain:
        files: [
          {
            expand: true
            cwd: projects.main.id
            src: [
#              "**/*.html"
            ]
            dest: BUILD_DIR + projects.main.id
            filter: 'isFile'
          }
        ]
      devServer:
        files: [
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
            cwd: BUILD_DIR + projects.server.id
            src: [
              "**/*"
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
        cwd: projects.main.id + SCRIPTS_DIR
        src: "**/*.coffee"
        dest: BUILD_DIR + projects.main.id + SCRIPTS_DIR
        ext: ".js"
      server:
        expand: true,
        cwd: projects.server.id
        src: "**/*.coffee"
        dest: BUILD_DIR + projects.server.id
        ext: ".js"

    # Create reference shortcuts
    symlink:
      components:
        dest: BUILD_DIR + projects.main.id + "/components"
        relativeSrc: "./../../bower_components/"
        options:
          type: "dir"
      build_public:
        dest: BUILD_DIR + projects.server.id + "/" + projects.server.public
        relativeSrc: "./../" + projects.main.id
      release_public:
        dest: RELEASE_DIR + projects.server.id + "/" + projects.server.public
        relativeSrc: "./../" + projects.main.id
      main:
        dest: BUILD_DIR + projects.main.id + "/" + npmPackage.main
        relativeSrc: "./../../" + projects.main.id + "/" + npmPackage.main
      html:
        dest: BUILD_DIR + projects.main.id + HTML_DIR
        relativeSrc: "./../../" + projects.main.id + HTML_DIR

    # Compile RequireJS main-app structure
    requirejs:
      compile:
        options:
          name: projects.main.name
          baseUrl: BUILD_DIR + projects.main.id + SCRIPTS_DIR
          mainConfigFile: BUILD_DIR + projects.main.id + SCRIPTS_DIR + projects.main.config
          exclude: projects.main.exludeDep
          include: [projects.main.config]
          out: [
            RELEASE_DIR
            projects.main.id
            SCRIPTS_DIR
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

    # Creates a small development server
    connect:
      main:
        options:
          # Creates server
          port: npmPackage.ports.main
          base: BUILD_DIR + projects.main.id
          # Injects livereload script into html
          livereload: npmPackage.ports.livereload
          # Setup livereload
          middleware: (connect, options) ->
            # Return connect to multiple operations
            [
              # Current server
              connect.static options.base
              # Livereload
              require('connect-livereload')
                port: npmPackage.ports.livereload
            ]

    # Watch for changes in development
    watch:
      options:
        livereload: npmPackage.ports.livereload
      html:
        files: [
          projects.main.id + "/" + npmPackage.main
        ]
      sass:
        files: [
          projects.main.id + STYLE_DIR + "**/*.sass"
        ]
        tasks: ["compass:dev"]
      coffee:
        files: [
          projects.main.id + SCRIPTS_DIR + "**/*.coffee"
        ]
        tasks: [
          "coffeelint"
          "coffee"
        ]


  # Load NPM modules
  matchdep = require "matchdep"
  matchdep.filterDev("grunt-*").forEach(grunt.loadNpmTasks)

  # Register Tasks
  for taskName, taskList of TASKS
    grunt.registerTask taskName, taskList