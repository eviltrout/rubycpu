require 'minitest/autorun'
require 'mocha'

module MiniTest
  module Assertions

    def assert_has_mask(number, mask)
      assert (number & mask) == mask, "Expected %b to have mask %b" % [number, mask]
    end

    def assert_contains_bits(number, mask, bits)
      assert (number & mask) == bits, "Expected %b to contain %b after mask with %b" % [number, bits, mask]
    end

  end
end

Numeric.infect_an_assertion :assert_contains_bits, :must_contain_bits, :do_not_flip
Numeric.infect_an_assertion :assert_has_mask, :must_have_mask, :only_one_argument
