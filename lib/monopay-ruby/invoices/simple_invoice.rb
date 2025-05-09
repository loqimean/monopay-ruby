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
      def create(amount, destination: nil, reference: nil)
        begin
          @amount = convert_to_cents(amount)
          @destination = destination
          @reference = reference

          response = RestClient.post(API_CREATE_INVOICE_URL, request_body, headers)
          response_body = JSON.parse(response.body)

          @page_url = JSON.parse(response.body)[PAGE_URL_KEY]
          @invoice_id = JSON.parse(response.body)[INVOICE_ID_KEY]

          true
        rescue RestClient::ExceptionWithResponse => e
          response_body = JSON.parse(e.response.body)
          @error_messages << [e.message, response_body].join(", ")
          # TODO: use errors and full_messages like rails
          # TODO: use logger to log errors or successful invoice creation

          false
        end
      end

      protected

      # Default params required for request to Monobank
      #
      # @return [Hash] default params
      def default_params
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
        }
      end

      # Request body required for Monobank API
      #
      # @return [Hash] request body
      def request_body
        default_params.to_json
      end

      def convert_to_cents(amount)
        if amount.is_a?(BigDecimal)
          Money.from_amount(amount, DEFAULT_CURRENCY).cents
        else
          amount
        end
      end
    end
  end
end
