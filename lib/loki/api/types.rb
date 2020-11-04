# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

require 'multi_json'

require 'internal/types'

module Loki
  module API
    module Types

      include Internal::Validation::Types

      module T
        include Dry.Types()
      end

      #######################################################################################
      #                                                                                     #
      #  Even though I've include Internal::Validation::Types I still need to use the full  #
      #  module path. I'm not sure why but I _suspect_ (this is complete conjecture by the  #
      #  way!) it's to do with include'ing Dry.types() in it's own module. The reason I     #
      #  suspect this is because I can and include Internal::Validation::Types in the       #
      #  T module and it works as you'd expect.                                             #
      #                                                                                     #
      #  I opted to use the full module path as it looks less odd than include'ing          #
      #  Internal::Validation::Types twice.                                                 #
      #                                                                                     #
      #######################################################################################

      class RangeQuery < Dry::Struct
        attribute   :query,   T::String.constrained(:min_size => 1)
        attribute   :start,   T::String.constrained(:format => Loki::API::Types::RFC3339_REGEX)
        attribute   :end,     T::String.constrained(:format => Loki::API::Types::RFC3339_REGEX)
        attribute   :step,    T::Integer.optional
      end

      class SnapshotQuery < Dry::Struct
        attribute   :query,   T::String
        attribute   :time,    T::String.constrained(:format => Loki::API::Types::RFC3339_REGEX).optional
      end

      Query = T::Instance(RangeQuery) | T::Instance(SnapshotQuery)
    end
  end
end
