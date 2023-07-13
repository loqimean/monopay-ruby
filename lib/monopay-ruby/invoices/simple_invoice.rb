require "bigdecimal"
require "money"

module MonopayRuby
  module Invoices
    class SimpleInvoice < MonopayRuby::Base
      attr_reader :invoice_id, :page_url, :error_messages, :amount, :destination, :reference, :redirect_url, :webhook_url

      API_CREATE_INVOICE_URL = "#{API_URL}/merchant/invoice/create".freeze

      DEFAULT_CURRENCY = "UAH".freeze

      PAGE_URL_KEY = "pageUrl".freeze
      INVOICE_ID_KEY = "invoiceId".freeze

      # Initialize SimpleInvoice
      #
      # @param [String] redirect_url - url where user will be redirected after payment
      # @param [String] webhook_url - url where Monobank will send webhook after payment
      def initialize(redirect_url = nil, webhook_url = nil)
        @redirect_url = redirect_url
        @webhook_url = webhook_url

        @error_messages = []
      end

      # Create invoice
      #
      # @param [BigDecimal,Integer] amount in UAH (cents) to request payment
      # @param [String] destination - additional info about payment
      # @param [String] reference - bill number or other reference
      # @return [Boolean] true if invoice was created successfully, false otherwise
      def create(amount, discount=100, discount_is_fixed=false, destination: nil, reference: nil)
        begin
          @amount = convert_to_cents(amount)
          @destination = destination
          @reference = reference
          discount = convert_discount(discount, discount_is_fixed)

          if discount_is_fixed || (discount < 1 && discount > 0)
            @amount = make_discount(discount, discount_is_fixed)
          end

          response = RestClient.post(API_CREATE_INVOICE_URL, request_body, headers)
          response_body = JSON.parse(response.body)

          @page_url = JSON.parse(response.body)[PAGE_URL_KEY]
          @invoice_id = JSON.parse(response.body)[INVOICE_ID_KEY]

          true
        rescue Exception => e
          response_body = JSON.parse(e.response.body)
          @error_messages << [e.message, response_body].join(", ")
          # TODO: use errors and full_messages like rails
          # TODO: use logger to log errors or successful invoice creation

          false
        end
      end

      private

      # Request body required for Monobank API
      #
      # @return [Hash] request body
      def request_body
        # TODO: add "ccy" and another missing params
        # TODO: remove nil valued params
        {
          amount: amount,
          redirectUrl: redirect_url,
          webHookUrl: webhook_url,
          merchantPaymInfo: {
            reference: reference,
            destination: destination
          }
        }.to_json
      end

      def convert_to_cents(amount)
        if amount.is_a?(BigDecimal)
          Money.from_amount(amount, DEFAULT_CURRENCY).cents
        elsif amount.is_a?(Integer)
          amount
        else
          raise TypeError, "allowed to use only a BigDecimal or Integer price"
        end
      end

      def convert_discount(discount, discount_is_fixed)
        if discount_is_fixed
          convert_to_cents(discount)
        else
          (1 - (discount.to_f / 100))
        end
      end

      def make_discount(discount, discount_is_fixed)
        sum = discount_is_fixed ? (@amount - discount) : (@amount * discount)
        puts MonopayRuby.configuration.min_value.class

        [sum.to_i, convert_to_cents(MonopayRuby.configuration.min_value)].max
      end
    end
  end
end
