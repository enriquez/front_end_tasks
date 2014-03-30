require 'thor'
require 'front_end_tasks'

module FrontEndTasks

  class CLI < Thor

    desc "build", "Builds the given files according to special build comments"
    method_option :js_concat_only, :type => :boolean
    method_option :result, :default => File.expand_path('./build')
    def build(public_dir, *files)
      FrontEndTasks.build(public_dir, options[:result], files, options)
    end

    desc "gzip", "Creates a compressed .gz version of the given file"
    def gzip(*files)
      FrontEndTasks.gzip(*files)
    end

    desc "server", "Run a static site directory on localhost"
    method_option :public_dir, :default => File.expand_path('./build')
    method_option :port, :default => 8000
    def server
      FrontEndTasks.server(options)
    end

    desc "lint", "Run JSLint"
    def lint(*files)
      FrontEndTasks.lint(*files)
    end

    desc "spec", "Run Jasmine specs"
    method_option :source_files, :type => :array
    method_option :worker_file
    method_option :public_root
    method_option :helper_files, :type => :array, :default => []
    method_option :spec_files, :type => :array
    method_option :port, :default => 8001
    def spec
      FrontEndTasks.spec(options)
    end

    desc "list_scripts", "List dependent javascript files"
    method_option :public_root
    def list_scripts(file)
      puts FrontEndTasks.list_scripts(file, options[:public_root])
    end

  end

end
