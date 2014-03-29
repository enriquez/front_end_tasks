module FrontEndTasks

  class Document
    attr_accessor :compiled_path

    def initialize(public_root, content)
      @public_root = public_root
      @content = content
    end

    def compile
      {
        @compiled_path => @content
      }
    end

  end

end
