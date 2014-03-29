require 'jasmine'

module FrontEndTasks
  class Spec
    ES5_SHIM    = File.expand_path(File.join(__dir__, '../..', 'vendor/es5-shim/es5-shim.js'))
    WORKER_SHIM = File.expand_path(File.join(__dir__, '../..', 'vendor/worker-shim/worker-shim.js'))

    # mostly taken from https://github.com/pivotal/jasmine-gem/blob/master/lib/jasmine/tasks/jasmine.rake
    def self.run(opts)
      config = Jasmine.config
      config.src_dir  = File.expand_path('./')
      config.spec_dir = File.expand_path('./')
      config.ci_port = opts[:port]

      if opts[:source_files]
        source_files = opts[:source_files]
      elsif opts[:worker_file]
        source_files = []
        source_files << '__worker-shim.js__'
        config.add_rack_path('/__worker-shim.js__', lambda { Rack::File.new(WORKER_SHIM) })
        js_doc = Documents::JsDocument.new(nil, File.read(opts[:worker_file]))
        source_files += js_doc.included_scripts.map { |s| File.join(opts[:public_root], s) }
        source_files << opts[:worker_file]
      end

      helper_files = opts[:helper_files] || []

      # hack the es5-shim to load before src files
      config.add_rack_path('/__es5-shim.js__', lambda { Rack::File.new(ES5_SHIM) })
      config.src_files  = lambda { ['__es5-shim.js__'] + source_files }
      config.spec_files = lambda { helper_files + opts[:spec_files] }

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

      exit(1) unless exit_code_formatter.succeeded?
    end

  end
end
