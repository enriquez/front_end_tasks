require 'thor'
require 'front_end_tasks/optimizer'

module FrontEndTasks

  class CLI < Thor

    desc "build", "Builds the given files according to special build comments"
    method_option :result, :default => File.expand_path('./build')
    def build(public_dir, *files)
      optimizer = Optimizer.new(public_dir, files)
      optimizer.build_to(options[:result])
    end

  end

end
