module MonopayRuby
  module Services
    class Discount < BaseService
      attr_reader :amount, :discount, :discount_is_fixed, :min_amount

      def initialize(amount, discount, discount_is_fixed, min_amount)
        @amount = amount
        @discount = discount
        @discount_is_fixed = discount_is_fixed
        @min_amount = min_amount
      end

      def call
        if discount_is_fixed
          sum = amount - discount
        else
          sum = amount * (1 - (discount.to_f / 100))
        end

        [sum.to_i, min_amount].max
      end
    end
  end
end