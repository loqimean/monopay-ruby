require "bigdecimal"

module MonopayRuby
  module Services
    class ValidateValue < BaseService
      attr_reader :amount, :currency, :type

      def initialize(amount, currency, type='Amount')
        @amount = amount
        @currency = currency
        @type = type
      end

      def call
        if amount.is_a?(Integer) || amount.is_a?(BigDecimal)
          if amount > 0
            MonopayRuby::Services::ConvertAmount.call(amount, currency)
          else
            raise ArgumentError, "#{type} must be greater than 0"
          end
        else
          raise TypeError, "#{type} is allowed to be Integer or BigDecimal, got #{amount.class}" unless amount.is_a?(Integer) || amount.is_a?(BigDecimal)
        end
      end

      private

      def name(var)
        binding.local_variables.each do |name|
          value = binding.local_variable_get(name)
          return name.to_s if value == var
        end
        nil
      end
    end
  end
end
