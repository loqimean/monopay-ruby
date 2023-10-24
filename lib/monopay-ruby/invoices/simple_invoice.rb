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
      def initialize(redirect_url: nil, webhook_url: nil)
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
      def create(amount:, options: {})
        @amount = amount
        discount = options[:discount]
        discount_is_fixed = options[:discount_is_fixed]
        @destination = options[:destination]
        @reference = options[:reference]

        begin
          @min_amount = MonopayRuby::Services::ValidateValue.call(MonopayRuby.configuration.min_price, DEFAULT_CURRENCY, "Minimal amount")
          @amount = MonopayRuby::Services::ValidateValue.call(amount, DEFAULT_CURRENCY)

          if discount
            discount = MonopayRuby::Services::ConvertAmount.call(discount, DEFAULT_CURRENCY)

            @amount = MonopayRuby::Services::Discount.call(@amount, discount, discount_is_fixed, @min_amount)
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
    end
  end
end
