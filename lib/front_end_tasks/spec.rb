require 'json'
require 'jasmine'
require 'jasmine/config'

module FrontEndTasks
  class Spec

    # taken from https://github.com/pivotal/jasmine-gem/blob/master/lib/jasmine/tasks/jasmine.rake
    def self.run(opts)
      config = Jasmine.config
      config.src_dir  = File.expand_path('./')
      config.spec_dir = File.expand_path('./')
      config.src_files  = lambda { opts[:source_files] }
      config.spec_files = lambda { opts[:helper_files] + opts[:spec_files] }

      server = Jasmine::Server.new(config.port(:ci), Jasmine::Application.app(config))
      t = Thread.new do
        begin
          server.start
        rescue ChildProcess::TimeoutError
        end
        # # ignore bad exits
      end
      t.abort_on_exception = true
      Jasmine::wait_for_listener(config.port(:ci), 'jasmine server')
      puts 'jasmine server started.'

      formatters = config.formatters.map { |formatter_class| formatter_class.new }

      exit_code_formatter = Jasmine::Formatters::ExitCode.new
      formatters << exit_code_formatter

      url = "#{config.host}:#{config.port(:ci)}/"
      runner = config.runner.call(Jasmine::Formatters::Multi.new(formatters), url)
      runner.run

      abort unless exit_code_formatter.succeeded?
    end

  end
end
