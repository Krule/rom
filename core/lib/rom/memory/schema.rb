require 'rom/schema'
require 'rom/memory/associations'

module ROM
  module Memory
    class Schema < ROM::Schema
      # @see Schema#call
      # @api public
      def call(relation)
        relation.new(relation.dataset.project(*map(&:name)), schema: self)
      end

      # @api private
      def finalize_associations!(relations:)
        super do
          associations.map do |definition|
            Memory::Associations.const_get(definition.type).new(definition, relations)
          end
        end
      end
    end
  end
end
