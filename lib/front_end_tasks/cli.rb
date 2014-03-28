require 'thor'
require 'front_end_tasks/optimizer'
require 'front_end_tasks/server'
require 'front_end_tasks/lint'

module FrontEndTasks

  class CLI < Thor

    desc "build", "Builds the given files according to special build comments"
    method_option :result, :default => File.expand_path('./build')
    def build(public_dir, *files)
      optimizer = Optimizer.new(public_dir, files)
      optimizer.build_to(options[:result])
    end

    desc "server", "Run a static site directory on localhost"
    method_option :public_dir, :default => File.expand_path('./build')
    method_option :port, :default => 8000
    def server()
      Server.start(options)
    end

    desc "lint", "Run JSLint"
    def lint(*files)
      Lint.report(files)
    end

    desc "spec", "Run Jasmine specs"
    def spec(directory)
      #TODO: run phantom js
    end

  end

end
