require 'nokogiri'
require 'uglifier'
require 'yui/compressor'

module FrontEndTasks

  class HtmlDocument

    def initialize(html_root, content)
      @html_root = html_root
      @doc = Nokogiri::HTML(content)
    end

    def compile
      new_files = {}

      script_groups.each do |group|
        files = compile_scripts_group(group)
        new_files.merge!(files)
      end

      style_groups.each do |group|
        files = compile_styles_group(group)
        new_files.merge!(files)
      end

      comments.each { |c| c.remove }

      new_files
    end

    def scripts
      script_nodes = @doc.xpath('//script')
      script_nodes.map { |n| n[:src] }
    end

    def to_html
      html = @doc.to_html.gsub(/\n\s*\n/, "\n")
    end

    protected

    def script_groups
      groups = groups_matching_opening_comment(/\s?build:script (\S+)\s?$/, :tag_name => 'script')
      groups.each do |group|
        group[:files] = group[:elements].map { |e| File.join(@html_root, e[:src]) }
        group[:combined_file_path] = group[:args][0]
      end
      groups
    end

    def style_groups
      groups = groups_matching_opening_comment(/\s?build:style (\S+)\s?$/, :tag_name => 'link')
      groups.each do |group|
        group[:files] = group[:elements].map { |e| File.join(@html_root, e[:href]) }
        group[:combined_file_path] = group[:args][0]
      end
      groups
    end

    def groups_matching_opening_comment(comment_regex, opts)
      tag_name = opts[:tag_name]
      groups = []
      comments.each do |comment|
        if comment.content =~ comment_regex
          opening_comment = comment
          elements = []

          # collect capture groups from comment_regex
          matches = $~.to_a
          matches.shift
          args = matches

          # collect all elements with tag_name that follow the opening_comment
          next_element = opening_comment.next_element
          while (next_element && next_element.name == tag_name) do
            elements << next_element
            next_element = next_element.next_element
          end

          groups << {
            :opening_comment => opening_comment,
            :elements => elements,
            :args => args
          }
        end
      end

      groups
    end

    def comments
      @comments ||= @doc.xpath('//comment()')
    end

    def replace_group(group, new_element)
      group[:elements].each { |e| e.remove }
      group[:opening_comment].add_next_sibling(new_element)
    end

    def compile_scripts_group(group)
      new_files = {}
      combined_file_path = group[:combined_file_path]
      combined_root = File.dirname(combined_file_path)

      combined_content, dependencies = parse_and_update_javascripts(combined_root, group[:files])

      dependencies.each_pair do |file_path, contents|
        combined_worker = parse_and_update_worker(contents)
        dependencies[file_path] = Uglifier.compile(combined_worker)
      end
      combined_content = Uglifier.compile(combined_content)

      new_files.merge!({
        combined_file_path => combined_content
      })
      new_files.merge!(dependencies)

      script_node = Nokogiri::XML::Node.new("script", @doc)
      script_node[:src] = combined_file_path
      replace_group(group, script_node)

      new_files
    end

    def compile_styles_group(group)
      new_files = {}
      combined_file_path = group[:combined_file_path]
      combined_root = File.dirname(combined_file_path)

      combined_content, dependencies = parse_and_update_stylesheets(combined_root, group[:files])

      compressor = YUI::CssCompressor.new
      combined_content = compressor.compress(combined_content)

      new_files.merge!({
        combined_file_path => combined_content
      })
      new_files.merge!(dependencies)

      link_node = Nokogiri::XML::Node.new("link", @doc)
      link_node[:href] = combined_file_path
      link_node[:rel] = "stylesheet"
      replace_group(group, link_node)

      new_files
    end

    def parse_and_update_javascripts(root, file_paths)
      output = ''
      workers = {}

      file_paths.each do |f|
        contents = File.read(f)

        worker_references = contents.scan(/Worker\(['"](.*)['"]\)/)
        worker_references.each do |worker_reference|
          url = worker_reference[0].strip
          filename = File.basename(url).split("?")[0].split("#")[0]
          local_file_path = File.expand_path(File.join(@html_root, File.dirname(url), filename))
          new_path = File.join(root, filename)

          # flatten url to down to just basename (including ? and # junk)
          contents.sub!(url, new_path)

          # get worker contents
          workers[new_path] = File.read(local_file_path)
        end

        output << contents
      end

      [output, workers]
    end

    def parse_and_update_worker(worker_content)
      output = ''

      import_scripts = worker_content.scan(/importScripts\(([^)]+)\)/)
      import_scripts.each do |import_script|
        argument_content = import_script[0]
        import_scripts_content = ''
        paths = argument_content.split(",").map { |p| p.strip.chop.reverse.chop.reverse }
        paths.each do |path|
          local_file_path = File.expand_path(File.join(@html_root, path))
          output << File.read(local_file_path)
        end
      end

      output << worker_content.gsub(/importScripts\(([^)]+)\);/, '')

      output
    end

    def parse_and_update_stylesheets(root, file_paths)
      output = ''
      dependencies = {}

      file_paths.each do |f|
        contents = File.read(f)

        url_references = contents.scan(/url\(\s?['"](.*?)['"]\s?\)/)
        url_references.each do |url_reference|
          url = url_reference[0].strip
          filename = File.basename(url).split("?")[0].split("#")[0]
          local_file_path = File.expand_path(File.join(File.dirname(f), File.dirname(url), filename))
          new_path = File.join(root, filename)

          # flatten url to down to just basename (including ? and # junk)
          contents.sub!(url, File.basename(url))

          # get dependency contents
          dependencies[new_path] = File.read(local_file_path)
        end

        output << contents
      end

      [output, dependencies]
    end

  end

end
