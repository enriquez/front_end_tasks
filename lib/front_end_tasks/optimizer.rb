require 'fileutils'
require 'front_end_tasks/html_document'

module FrontEndTasks

  class Optimizer

    def initialize(public_dir, files)
      @public_dir = File.expand_path(public_dir)
      @files    = files.map { |f| File.expand_path(f) }
    end

    def build_to(result_dir)
      @files.each do |file|

        if (File.extname(file) == '.html')
          html_filename = File.basename(file)
          html_doc = HtmlDocument.new(@public_dir, File.read(file))
          html_doc.compiled_path = html_filename

          files = html_doc.compile

          files.each_pair do |file, contents|
            save_file(File.join(result_dir, file), contents)
          end
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
