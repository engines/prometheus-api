# frozen_string_literal: true

require 'pathname'
require 'addressable'
require 'time'

require 'dry-monads'

require 'prometheus/api/client'
require 'prometheus/api/types'

puts "#####################################################################"
puts
puts "This is ~a bit~ very shit as it requires a running prometheus server"
puts
puts "#####################################################################"

include Dry::Monads[:result]
include Prometheus::API::Types

uri = Addressable::URI.parse("http://localhost:9090")

describe Prometheus::API::Client do
  describe "#query" do
    it "execute a snapshot query returning the lastest value" do
      q = "rate(container_network_transmit_bytes_total[1m])"
      query = SnapshotQuery.new(:query => q, :time => nil)
      client = Prometheus::API::Client.new(uri)

      expect(client.query(query)).to be_a(Success)
    end

    it "validate a specific time" do
      timestamp = "2020-02-29T18:30:27+11:00"

      expect(RFC3339_REGEX.match?(timestamp)).to be(true)
    end

    it "execute a snapshot query returning the value for the specified time" do
      query = 'up{instance="grenadier.int.filterfish.org:4194"}'
      timestamp = "2020-10-14T18:30:27+11:00"

      res = Prometheus::API::Client.new(uri).query(SnapshotQuery.new(:query => query, :time => timestamp))

      expect(res).to eq(Success({"resultType" => "vector", "result" =>
                                [{"metric" => {"__name__" => "up", "instance" => "grenadier.int.filterfish.org:4194",
                                "job" => "node"}, "value" => [1602660627, "1"]}]}))
    end

    it "execute a range query returning the value for the specified interval" do
      q = 'up{instance="grenadier.int.filterfish.org:4194"}'
      timestamp = Time.parse("2020-10-14T18:30:27+11:00")
      start = timestamp.strftime(RFC3339_FMT)
      finish = (timestamp + 2).strftime(RFC3339_FMT)

      query = RangeQuery.new(:query => q, :start => start, :end => finish, :step => 1)
      res = Prometheus::API::Client.new(uri).query(query)

      expect(res).to eq(Success({"resultType" => "matrix", "result" =>
                                [{"metric" => {"__name__" => "up", "instance" => "grenadier.int.filterfish.org:4194",
                                "job" => "node"}, "values" =>
                                [[1602660627, "1"], [1602660628, "1"], [1602660629, "1"]]}]}))
    end
  end
end
