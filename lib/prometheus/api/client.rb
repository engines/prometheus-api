# frozen_string_literal: true

require 'faraday'
require 'addressable'

require 'dry-monads'
require 'dry-struct'
require 'dry-types'

require 'multi_json'

require 'prometheus/api/types'

module Prometheus
  module API
    class Client

      include Dry::Monads[:result]
      include Types

      DEFAULT_URI = Addressable::URI.new(:scheme => "http", :host => "localhost", :port => 9090)
      DEFAULT_PATH = "/api/v1/"


      # Initialise the Prometues client.
      #
      # @param base_uri [Addressable::URI] The base URI of the Prometheus server.
      #                                    For example http://localhost:9090
      # @param options [Hash<:symbol, String>] An options Hash which is pass directly to Paraday.
      # @return [Result<Any|String>] The return value. On {Success}, the return JSON, value from Prometheus
      #                              and on {Failure} a {String} containing the reason why it failed.
      def initialize(base_uri=nil, options={})
        uri = (base_uri.nil?) ? DEFAULT_URI : base_uri
        uri.path = DEFAULT_PATH
        @client = Faraday.new(uri, options)
      end

      # Run a query againt a Prometheus database
      #
      # @param query [Query] the query to run
      # @return [Result<Any|String>] the return value from prometheus
      def query(query)
        case query
        when RangeQuery
          get("query_range", query.to_h)
        when SnapshotQuery
          get("query", query.to_h)
        else
          raise Runtime, "Unknown query type" # The type system should catch this when we use it.
        end
      end


      private

      attr_reader :client

      # Send a GET to the Prometheus server. This does a case analysis on the result
      # ensuring error messages are handled properly.
      #
      # @param query_type [String] The type query of query. This cae be either
      #                            "query" or "query_range".
      # @param query [Query] the query to run against the Prometheus server.
      #
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def get(query_type, options)
        begin
          res = client.get(query_type, options)
          case res.status
          when 200
            Success(res.env[:body])
          when 400
            Failure(MultiJson.load(res.env[:body])["error"])
          when 422
            Failure("Unprocessable Entity: the request was well formed but cannot be executed (RFC4918)")
          when 503
            Failure("Service Unavailable: The Prometheus server has either timed out or aborted the query")
          else
            Failure(res.env[:body])
          end
        rescue Faraday::ConnectionFailed => e
          Failure(e.message)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def extract_error(e)
        MultiJson.load(e)["error"]
      end
    end
  end
end
