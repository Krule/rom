require 'rom/types'
require 'rom/associations/definitions/abstract'

module ROM
  module Associations
    module Definitions
      class ManyToMany < Abstract
        result :many

        option :through, reader: true

        # @api private
        def through_relation
          through.relation
        end

        # @api private
        def through_assoc_name
          through.assoc_name
        end
      end
    end
  end
end
