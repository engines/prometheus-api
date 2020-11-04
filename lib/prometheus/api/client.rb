# frozen_string_literal: true

require 'faraday'
require 'addressable'

require 'multi_json'

require 'internal/client'
require 'prometheus/api/types'

module Prometheus; module API; end; end

class Prometheus::API::Client < Internal::Client

  include Prometheus::API::Types

  DEFAULT_PATH = "/api/v1/"
  DEFAULT_URI = Addressable::URI.new(:scheme => "http", :host => "localhost", :port => 9090, :path => DEFAULT_PATH)


  # Initialise the Prometues client.
  #
  # @param base_uri [Addressable::URI] The base URI of the Prometheus server. For example http://localhost:9090.
  #                                    Note, if the path is set it will be discarded
  # @param options [Hash<:symbol, String>] An options Hash which is pass directly to Paraday.
  # @return [Result<Any|String>] The return value. On {Success}, the return JSON, value from Prometheus
  #                              and on {Failure} a {String} containing the reason why it failed.
  def initialize(base_uri=nil, options={})
    uri = (base_uri.nil?) ? DEFAULT_URI : base_uri
    uri.path = DEFAULT_PATH
    super uri, options
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
end
