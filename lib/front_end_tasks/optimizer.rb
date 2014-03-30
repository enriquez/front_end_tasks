require 'fileutils'
require 'front_end_tasks/documents'

module FrontEndTasks

  class Optimizer

    def initialize(public_dir, files)
      @public_dir = File.expand_path(public_dir)
      @files    = files.map { |f| File.expand_path(f) }
    end

    def build_to(result_dir, opts = {})
      @files.each do |file|
        doc = Documents.create(@public_dir, file)
        doc.compiled_path = File.basename(file)
        files = doc.compile(opts)

        files.each_pair do |file, contents|
          save_file(File.join(result_dir, file), contents)
        end
      end
    end

    protected

    def save_file(file_with_path, contents)
      full_path = File.expand_path(file_with_path)
      directory = File.dirname(full_path)

      FileUtils.mkdir_p directory
      File.write(full_path, contents)
    end

  end

end
