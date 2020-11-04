# frozen_string_literal: true

require 'faraday'
require 'addressable'

require 'dry-monads'
require 'multi_json'


module Internal
  class Client

    include Dry::Monads[:result]


    # Initialise the client.
    #
    # @param base_uri [Addressable::URI] The base URI of the server. For example http://localhost:9090
    # @param options [Hash<:symbol, String>] An options Hash which is pass directly to Paraday.
    # @return [Result<Any|String>] The return value. On {Success}, the return JSON, value from the server
    #                              and on {Failure} a {String} containing the reason why it failed.
    def initialize(base_uri, options={})
      @client = Faraday.new(base_uri, options.merge({:headers => default_headers}))
    end

    private

    attr_reader :client

    # Send a GET to the server. This does a case analysis on the
    # result ensuring error messages are handled properly.
    #
    # @param query_type [String] The type query of query. This cae be either
    #                            "query" or "query_range".
    # @param query [Query] the query to run against the server.
    #
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def get(query_type, options)
      begin
        res = client.get(query_type, options)
        case res.status
        when 200
          Success(MultiJson.load(res.env[:body])["data"])
        when 400
          # This little gem of inconsitency is because Promeheus returns error messages as
          # json (correct) and Loki returns plain text (wrong). I have opened an issue ...
          begin
            Failure(MultiJson.load(res.env[:body])["error"])
          rescue MultiJson::ParseError
            Failure(res.env[:body])
          end
        when 422
          Failure("Unprocessable Entity: the request was well formed but cannot be executed (RFC4918)")
        when 503
          Failure("Service Unavailable: The server has either timed out or aborted the query")
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

    def default_headers
      {"Accept" => "application/json", "User-Agent" => "Engines Ruby Client"}
    end
  end
end
