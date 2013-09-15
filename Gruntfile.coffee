LIVERELOAD_PORT = 35729
lrSnippet = require('connect-livereload') { port: LIVERELOAD_PORT }
mountFolder = (connect, dir) ->
  connect.static require('path').resolve(dir)

module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  grunt.initConfig
    watch:
      options:
        nospawn: true
        livereload: LIVERELOAD_PORT
      livereload:
        files: ['app/assets/index.html', 'test/assets/index.html', 'app/**/*.coffee', 'test/**/*.coffee', 'app/**/*.styl']
        tasks: ['build']

    cssmin:
      combine:
        files:
          'public/test/stylesheets/test.css': ['test/vendor/stylesheets/*.css']

    mocha:
      options:
        reporter: 'Spec'
      all: ['public/test/index.html']

    blanket:
      instrument:
        files:
          'public/test/javascripts/': ['public/javascripts/']

    coffee:
      app:
        options:
          bare: true
        expand: true
        flatten: false
        cwd: 'app/'
        src: ['**/*.coffee']
        dest: 'public/raw-javascripts/'
        ext: '.js'

    commonjs:
      modules:
        cwd: 'public/raw-javascripts/'
        src: ['**/*.js']
        dest: 'public/javascripts/'

    tusk_coffee:
      app:
        options:
          wrap: "CommonJS"
          modulesRoot: "app"
          runtime: false
        files:
          'public/javascripts/app.js': ['app/**/*.coffee']
      test:
        options:
          wrap: 'CommonJS'
          runtime: false
        files:
          'public/test/javascripts/test.js': ['test/**/*.coffee']
      vendor:
        options:
          wrap: null
          runtime: false
        files:
          'public/javascripts/vendor.js': ['vendor/javascripts/*.js']
          'public/test/javascripts/test-vendor.js': ['test/vendor/javascripts/*.js']

    clean:
      build: [
        'public'
        'docs'
      ]

    connect:
      options:
        port: 3333
        hostname: '0.0.0.0'
        base: 'public'
      livereload:
        middlewear: (connect) ->
          [lrSnippet, mountFolder(connect, '.')]

    open:
      server:
        path: 'http://localhost:<%= connect.options.port %>'

    copy:
      main:
        files: [
          {expand: true, cwd: 'app/assets/', src: ['**'], dest: 'public'}
          {expand: true, cwd: 'app/assets/images', src: ['**'], dest: 'public/test/images'}
          {expand: true, src: ['test/assets/*'], dest: 'public/test', flatten: true}
        ]

    docco:
      coffee:
        options:
          output: 'public/docs/'
          seperator: '_'
          cwd: 'app'
        src: ['app/**/*.coffee']

  grunt.registerTask 'live', ['build', 'connect:livereload', 'watch']

  grunt.registerTask 'tdd', ['deploy', 'test', 'watch']

  grunt.registerTask 'serve', ['deploy', 'connect:livereload', 'watch']

  grunt.registerTask 'build', ['deploy', 'test']

  grunt.registerTask 'deploy', ['clean', 'coffee', 'commonjs', 'tusk_coffee', 'cssmin', 'docs', 'copy']

  grunt.registerTask 'test', ['blanket', 'mocha']

  grunt.registerTask 'docs', ['docco']
