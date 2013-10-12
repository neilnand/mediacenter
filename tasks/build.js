var connectLivereload = require('connect-livereload');

var config = {

    pkg: require('../package.json'),

    coffeelint: {
        options: {
            max_line_length: { value: 200 },
            no_trailing_whitespace: { level: 'ignore' }
        },
        app: ['app/**/*.coffee'],
        tests: ['tests/**/*.coffee']
    },

    clean: {
        tmp: 'temp',
        dist: 'dist'
    },

    coffee: {
        scripts: {
            expand: true,
            cwd: 'app/scripts',
            src: '**/*.coffee',
            dest: 'temp/scripts',
            ext: '.js'
        }
    },

    symlink: {
        components: {
            dest: 'temp/components',
            relativeSrc: '../bower_components',
            options: { type: 'dir' }
        }
    },

    requirejs: {
        compile: {
            options: {
                mainConfigFile: 'temp/scripts/config.js',
                name: "mediacenter",
                out: 'dist/<%= pkg.name %>.js',
                exclude: ['Angular', 'webUtils'],
                include: ['config'],
                optimize: 'none'
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
        'coffee',
        'symlink',
        'requirejs',
        'copy'
    ]);
};
