'use strict';

var connectLivereload = require('connect-livereload'),
    pkg = require('../package.json');

var config = {
    pkg: pkg,
    coffeelint: {
        options: { max_line_length: { value: 120 } },
        app: ['app/**/*.coffee'],
        tests: {
            files: { src: ['tests/**/*.coffee'] },
            options: { 'no_trailing_whitespace': { 'level': 'error' } }
        }
    },
    clean: {
        tmp: 'tmp'
    },
    coffee: {
        scripts: { expand: true,
            cwd: 'app/scripts',
            src: '**/*.coffee',
            dest: 'tmp/scripts',
            ext: '.js'
        },
        tests: {
            expand: true,
            cwd: 'test/spec',
            src: '**/*.coffee',
            dest: 'tmp/test/spec',
            ext: '.js'
        },
        server: {
            expand: true,
            cwd: 'app/<%= pkg.config.src %>',
            src: '**/*.coffee',
            dest: 'tmp/scripts',
            ext: '.js'
        }
    },
    copy: {
        assets: {
            files: [{
                expand: true,
                cwd: 'app',
                src: ['index.html'],
                dest: 'tmp'
            }, {
                expand: true,
                cwd: 'app/<%= pkg.config.src %>',
                src: ['**/*', '!**/*.coffee'],
                dest: 'tmp/scripts'
            }]
        },
        scripts: {
            files: [{
                expand: true,
                cwd: 'app/<%= pkg.config.src %>',
                src: ['**/*', '!**/*.coffee', '!**/*.sass'],
                dest: 'tmp/scripts'
            }]
        }
    },
    symlink: {
        components: {
            dest: 'tmp/components',
            relativeSrc: '../bower_components',
            options: { type: 'dir' }
        }
    },
    compass: {
        server: {
            options: {
                sassDir: 'app/<%= pkg.config.src %>/styles',
                cssDir: 'tmp/styles'
            }
        }
    },
    connect: {
        options: { port: pkg.config.server.port, hostname: 'localhost' },
        livereload: { options: {
            middleware: function (connect) {
                return [connectLivereload({
                    port: pkg.config.livereload.port
                }), connect.static(__dirname + '/../tmp')];
            }
        }}
    },
    open: { server: { url: 'http://localhost:<%= pkg.config.server.port %>' } },
    watch: {
        options: { spawn: false },
        assets: {
            files: ['app/index.html', 'app/<%= pkg.config.src %>/**/*', '!app/<%= pkg.config.src %>/**/*.coffee'],
            tasks: ['copy:assets', 'ping'],
            options: { livereload: pkg.config.livereload.port }
        },
        scripts: {
            options: { livereload: pkg.config.livereload.port },
            files: ['app/scripts/**/*.coffee', 'app/<%= pkg.config.src %>/**/*.coffee'],
            tasks: ['coffee:scripts', 'coffee:server', 'ping'],
        },
        styles: {
            options: { livereload: pkg.config.livereload.port },
            files: ['app/<%= pkg.config.src %>/styles/**/*.sass'],
            tasks: ['compass', 'ping']
        },
        tests: {
            files: ['test/spec/**/*.coffee'],
            tasks: ['coffee:tests', 'ping']
        },
        livereload: {
            options: { livereload: pkg.config.livereload.port },
            files: ['tmp/scripts/**/*.js']
        }
    }
}


module.exports = function(grunt) {

    grunt.task.registerTask('ping', 'pings grunt to rebuild the project', function(){
        grunt.util.spawn({
            grunt: true,
            args: ['build']
        }, function(err, res, code){});
    });

    grunt.initConfig(config);

    grunt.registerTask('run', [
        'coffeelint',
        'clean',
        'coffee',
        'copy',
        'symlink',
        'compass',
        'connect',
        'open',
        'watch'
    ]);
};