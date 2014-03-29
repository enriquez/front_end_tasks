require 'yui/compressor'
require 'front_end_tasks/document'

module FrontEndTasks

  class CssDocument

    attr_accessor :compiled_path

    def initialize(public_root, content)
      @public_root = public_root
      @content = content
    end

    def compile
      compressor = YUI::CssCompressor.new
      compiled_content = compressor.compress(@content)

      { @compiled_path => compiled_content }
    end

    def self.find_and_update_url_references(css_root, new_root, content)
      assets = []
      updated_content = content

      url_references = content.scan(/url\(\s?['"](.*?)['"]\s?\)/)
      url_references.each do |url_reference|
        url = url_reference[0].strip
        filename = File.basename(url).split("?")[0].split("#")[0]
        local_file_path = File.join(css_root, File.dirname(url), filename)
        new_path = File.join(new_root, filename)

        # flatten url to down to just basename (including ? and # junk)
        updated_content.sub!(url, File.basename(url))

        # get asset contents
        asset = Document.new(css_root, File.read(local_file_path))
        asset.compiled_path = new_path
        assets << asset
      end

      [updated_content, assets]
    end

  end

end
