require "front_end_tasks/version"

require 'front_end_tasks/optimizer'
require 'front_end_tasks/server'
require 'front_end_tasks/lint'
require 'front_end_tasks/spec'
require 'front_end_tasks/documents'

module FrontEndTasks

  def self.build(public_dir, build_dir, *files)
    optimizer = Optimizer.new(public_dir, files)
    optimizer.build_to(build_dir)
  end

  def self.server(options)
    Server.start(options)
  end

  def self.lint(*files)
    Lint.report(files)
  end

  def self.spec(options)
    Spec.run(options)
  end

  def self.list_scripts(file, public_root = nil)
    content = File.read(File.expand_path(file))
    extension = File.extname(file).downcase
    doc = nil

    if extension == '.html'
      doc = Documents::HtmlDocument.new(nil, content)
    elsif extension == '.js'
      doc = Documents::JsDocument.new(nil, content)
    end

    doc.included_scripts(public_root)
  end

end
