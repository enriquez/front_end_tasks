require 'nokogiri'
require 'front_end_tasks/documents/base_document'
require 'front_end_tasks/documents/js_document'
require 'front_end_tasks/documents/css_document'

module FrontEndTasks
  module Documents
    class HtmlDocument < BaseDocument

      def initialize(public_root, content)
        super(public_root, content)
        @doc = Nokogiri::HTML(content)
      end

      def compile
        path_content_pairs = {}

        script_groups.each do |group|
          combined_content = group[:files].inject('') { |content, file| content << File.read(file) }
          combined_file_path = group[:combined_file_path]
          js_document = JsDocument.new(@public_root, combined_content)
          js_document.compiled_path = combined_file_path
          new_files = js_document.compile

          script_node = Nokogiri::XML::Node.new("script", @doc)
          script_node[:src] = combined_file_path
          replace_group(group, script_node)

          path_content_pairs.merge!(new_files)
        end

        style_groups.each do |group|
          combined_file_path = group[:combined_file_path]
          combined_content = ''

          group[:files].each do |file|
            content = File.read(file)
            updated_content, assets = CssDocument.find_and_update_url_references(File.dirname(file), File.dirname(combined_file_path), content)

            assets.each do |asset|
              new_files = asset.compile
              path_content_pairs.merge!(new_files)
            end

            combined_content << updated_content
          end

          css_document = CssDocument.new(@public_root, combined_content)
          css_document.compiled_path = combined_file_path
          new_files = css_document.compile

          link_node = Nokogiri::XML::Node.new("link", @doc)
          link_node[:href] = combined_file_path
          link_node[:rel] = "stylesheet"
          replace_group(group, link_node)

          path_content_pairs.merge!(new_files)
        end

        comments.each { |c| c.remove }

        path_content_pairs.merge!({
          @compiled_path => @doc.to_html.gsub(/\n\s*\n/, "\n")
        })

        path_content_pairs
      end

      def included_scripts(public_root)
        script_nodes = @doc.xpath('//script')
        script_nodes.map { |n| n[:src] }
        script_nodes.map do |node|
          if public_root
            File.expand_path(File.join(public_root, node[:src]))
          else
            node[:src]
          end
        end
      end

      protected

      def script_groups
        groups = groups_matching_opening_comment(/\s?build:script (\S+)\s?$/, :tag_name => 'script')
        groups.each do |group|
          group[:files] = group[:elements].map { |e| File.join(@public_root, e[:src]) }
          group[:combined_file_path] = group[:args][0]
        end
        groups
      end

      def style_groups
        groups = groups_matching_opening_comment(/\s?build:style (\S+)\s?$/, :tag_name => 'link')
        groups.each do |group|
          group[:files] = group[:elements].map { |e| File.join(@public_root, e[:href]) }
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

    end
  end
end
