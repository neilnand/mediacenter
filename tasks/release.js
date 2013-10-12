var connectLivereload = require('connect-livereload');

var config = {

    pkg: require('../package.json'),

    coffeelint: {
        options: { max_line_length: { value: 120 } },
        app: ['app/**/*.coffee'],
        tests: {
            files: { src: ['test/spec/*.coffee'] },
            options: { 'no_trailing_whitespace': { 'level': 'error' } }
        }
    },

    clean: {
        tmp: 'tmp',
        dist: 'dist',
        doc: 'doc'
    },

    yuidoc: {
        doc: {
            options: {
                name: 'imag-web-core',
                description: 'mediacenter docs',
                extension: '.coffee',
                paths: 'app/scripts',
                outdir: 'doc/',
                syntaxtype: 'coffee'
            }
        }
    },

    coffee: {
        scripts: {
            expand: true,
            cwd: 'app/scripts',
            src: '**/*.coffee',
            dest: 'tmp/scripts',
            ext: '.js'
        }
    },

    symlink: {
        components: {
            dest: 'tmp/components',
            relativeSrc: '../bower_components',
            options: { type: 'dir' }
        }
    },

    requirejs: {
        compile: {
            options: {
                mainConfigFile: 'tmp/scripts/config.js',
                name: "ImagWebCore",
                out: 'dist/<%= pkg.name %>.js',
                exclude: ['Angular', 'webUtils'],
                include: ['config']
            }
        }
    },

    copy: {
        bower: { files: [{ src: 'bower.json', dest: 'dist/' }] }
    }
}

module.exports = function(grunt) {

    grunt.initConfig(config);

    grunt.registerTask('run', [
        'coffeelint',
        'clean',
        'yuidoc',
        'coffee',
        'symlink',
        'requirejs',
        'copy'
    ]);
};
