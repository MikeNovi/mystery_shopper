require 'mystery_shopper'

require 'minitest/spec'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'minitest/stub_any_instance'

class MiniTest::Unit::TestCase
  def before_setup
    super
    Typhoeus::Expectation.clear
  end
end