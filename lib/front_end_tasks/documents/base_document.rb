module FrontEndTasks
  module Documents
    class BaseDocument

      attr_accessor :compiled_path

      def initialize(public_root, content)
        @public_root = public_root
        @content     = content
      end

      def compile(opts = {})
        raise NotImplementedError.new('Must override "compile" in subclass')
      end

    end
  end
end
