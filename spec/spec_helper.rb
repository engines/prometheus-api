# frozen_string_literal: true

require 'pathname'
require 'rspec'

$LOAD_PATH.unshift(Pathname.new(__FILE__).parent.dirname.join('lib').expand_path)
