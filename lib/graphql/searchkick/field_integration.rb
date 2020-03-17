# frozen_string_literal: true

module GraphQL
  module Searchkick
    module FieldIntegration

      module HasSearchkickField
        def initialize(*args, search: nil, **kwargs, &block)
          super(*args, **kwargs, &block)
          if search
            extension(GraphQL::Searchkick::SearchableExtension, model_class: search)
          end
        end
      end

      def self.included(field_class)
        field_class.include(HasSearchkickField)
      end

    end
  end
end
