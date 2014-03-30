require 'uglifier'
require 'front_end_tasks/documents/base_document'

module FrontEndTasks
  module Documents
    class JsDocument < BaseDocument

      def compile(opts = {})
        path_content_pairs = {}

        workers = find_worker_references(@public_root, @content)
        workers.each do |worker|
          new_files = worker.compile
          path_content_pairs.merge!(new_files)
        end

        @content = replace_worker_import_scripts(@public_root, @content)

        if opts[:js_concat_only]
          path_content_pairs.merge!({
            @compiled_path => @content
          })
        else
          compiled_content = Uglifier.compile(@content)
          path_content_pairs.merge!({
            @compiled_path => compiled_content
          })
        end

        path_content_pairs
      end

      def included_scripts(public_root = nil)
        paths = []

        import_scripts = @content.scan(/importScripts\(([^)]+)\)/)
        import_scripts.each do |import_script|
          argument_content = import_script[0]
          paths = argument_content.split(",").map { |p| p.strip.chop.reverse.chop.reverse }
        end

        paths.map do |path|
          if public_root
            File.expand_path(File.join(public_root, path))
          else
            path
          end
        end
      end

      protected
      def find_worker_references(public_root, content)
        workers = []

        worker_references = content.scan(/Worker\(['"](.*)['"]\)/)
        worker_references.each do |worker_reference|
          url = worker_reference[0].strip
          filename = File.basename(url).split("?")[0].split("#")[0]
          local_file_path = File.expand_path(File.join(public_root, File.dirname(url), filename))

          # get worker contents
          worker = self.class.new(public_root, File.read(local_file_path))
          worker.compiled_path = url
          workers << worker
        end

        workers
      end

      def replace_worker_import_scripts(public_root, content)
        updated_content = ''

        included_scripts(public_root).each do |path|
          updated_content << File.read(path)
        end

        # append the rest of the worker contents
        updated_content << content.gsub(/importScripts\(([^)]+)\);/, '')

        updated_content
      end

    end
  end
end
