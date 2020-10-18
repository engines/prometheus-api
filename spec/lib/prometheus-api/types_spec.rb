# frozen_string_literal: true

require 'pathname'
require 'addressable'
require 'time'

require 'dry-monads'

require 'prometheus-api/client'
require 'prometheus-api/types'

puts "#####################################################################"
puts
puts "This is ~a bit~ very shit as it requires a running prometheus server"
puts
puts "#####################################################################"

include Dry::Monads[:result]


uri = Addressable::URI.parse("http://prometheus.int.filterfish.org:9090")

describe Prometheus::Client do
  describe "#query" do
    it "execute a snapshot query returning the lastest value" do
      q = "rate(container_network_transmit_bytes_total[1m])"
      query = Prometheus::Types::SnapshotQuery.new(:query => q, :time => nil)
      client = Prometheus::Client.new(uri)

      expect(client.query(query)).to be_a(Success)
    end

    it "validate a specific time" do
      timestamp = "2020-02-29T18:30:27+11:00"

      expect(Prometheus::Client::RFC3339_REGEX.match?(timestamp)).to be(true)
    end

    it "execute a snapshot query returning the value for the specified time" do
      query = 'up{instance="grenadier.int.filterfish.org:4194"}'
      timestamp = "2020-10-14T18:30:27+11:00"

      res = Prometheus::Client.new(uri).query(Prometheus::Types::SnapshotQuery.new(:query => query, :time => timestamp))

      expect(res).to eq(Success('{"status":"success","data":{"resultType":"vector","result":[{"metric":' \
                                '{"__name__":"up","instance":"grenadier.int.filterfish.org:4194","job":"node"},' \
                                '"value":[1602660627,"1"]}]}}'))
    end

    it "execute a range query returning the value for the specified interval" do
      q = 'up{instance="grenadier.int.filterfish.org:4194"}'
      timestamp = Time.parse("2020-10-14T18:30:27+11:00")
      start = timestamp.strftime(Prometheus::Client::RFC3339_FMT)
      finish = (timestamp + 2).strftime(Prometheus::Client::RFC3339_FMT)

      query = Prometheus::Types::RangeQuery.new(:query => q, :start => start, :end => finish, :step => 1)
      res = Prometheus::Client.new(uri).query(query)

      expect(res).to eq(Success('{"status":"success","data":{"resultType":"matrix","result":[{"metric"' \
                                ':{"__name__":"up","instance":"grenadier.int.filterfish.org:4194","job":"node"},' \
                                '"values":[[1602660627,"1"],[1602660628,"1"],[1602660629,"1"]]}]}}'))
    end
  end
end
