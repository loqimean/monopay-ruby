require "money"
require "bigdecimal"

module MonopayRuby
  module Services
    class ConvertAmount < BaseService
      attr_reader :amount, :currency

      def initialize(amount, currency)
        @amount = amount
        @currency = currency
      end

      def call
        if amount.is_a?(BigDecimal)
          Money.from_amount(amount, currency).cents
        elsif amount.is_a?(Integer)
          amount
        else
          raise TypeError, "allowed to use only a BigDecimal or Integer type"
        end
      end
    end
  end
end
