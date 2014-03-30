require 'front_end_tasks/documents/base_document'
require 'front_end_tasks/documents/asset_document'
require 'front_end_tasks/documents/css_document'
require 'front_end_tasks/documents/js_document'
require 'front_end_tasks/documents/html_document'

module FrontEndTasks::Documents

  def self.create(public_dir, file)
    extension = File.extname(file).downcase
    contents  = File.read(file)

    case extension
    when '.html'
      HtmlDocument.new(public_dir, contents)
    when '.js'
      JsDocument.new(public_dir, contents)
    when '.css'
      CssDocument.new(public_dir, contents)
    else
      AssetDocument.new(public_dir, contents)
    end
  end

end
