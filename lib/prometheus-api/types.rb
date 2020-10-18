# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

require 'multi_json'

module Prometheus
  module Types

    # This regex is from: https://mattallan.me/posts/rfc3339-date-time-validation/
    #
    # Which itself is based on https://tools.ietf.org/html/rfc3339#section-5.6
    # without the extensions in secetion 5.7 which relate to leap seconds
    # I'm ok with that!
    DATE_REGEX = /^(?<fullyear>\d{4})-(?<month>0[1-9]|1[0-2])-(?<mday>0[1-9]|[12][0-9]|3[01])/.freeze
    TIME_REGEX = /(?<hour>[01][0-9]|2[0-3]):(?<minute>[0-5][0-9]):(?<second>[0-5][0-9]|60)(?<secfrac>\.[0-9]+)?/.freeze
    OFFSET_REGEX = /(Z|(\+|-)(?<offset_hour>[01][0-9]|2[0-3]):(?<offset_minute>[0-5][0-9]))$/.freeze

    RFC3339_REGEX = /#{DATE_REGEX}[T ]#{TIME_REGEX}#{OFFSET_REGEX}/i.freeze

    RFC3339_FMT = "%FT%T%:z"

    module T
      include Dry.Types()
    end

    class RangeQuery < Dry::Struct
      attribute   :query,   T::String
      attribute   :start,   T::String.constrained(:format => RFC3339_REGEX)
      attribute   :end,     T::String.constrained(:format => RFC3339_REGEX)
      attribute   :step,    T::Integer.optional
    end

    class SnapshotQuery < Dry::Struct
      attribute   :query,   T::String
      attribute   :time,    T::String.constrained(:format => RFC3339_REGEX).optional
    end

    Query = T::Instance(RangeQuery) | T::Instance(SnapshotQuery)
  end
end
