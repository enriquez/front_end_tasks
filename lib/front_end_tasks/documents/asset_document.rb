require 'front_end_tasks/documents/base_document'

module FrontEndTasks
  module Documents
    class AssetDocument < BaseDocument

      def compile
        {
          @compiled_path => @content
        }
      end

    end
  end
end
