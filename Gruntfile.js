(function() {
    'use strict';

    var matchdep = require('matchdep');

    exports = module.exports = function(grunt) {

        matchdep.filterDev('grunt-*').forEach(grunt.loadNpmTasks);

        ['server', 'release', 'build'].forEach(function(task){
            grunt.registerTask(task, function(){
                require('./tasks/' + task)(grunt);
                grunt.task.run('run');
            });
        });
    }
})();
