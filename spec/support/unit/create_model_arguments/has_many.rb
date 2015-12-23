module UnitTests
  module CreateModelArguments
    class HasMany < Basic
      def columns
        super.except(attribute_name)
      end

      private

      def default_attribute_name
        :children
      end
    end
  end
end
