require "rest-client"
require "base64"
require "json"

module MonopayRuby
  module Webhooks
    class PublicKey < MonopayRuby::Base
      attr_reader :error_messages, :key

      API_GET_KEY_URL = "#{API_URL}/merchant/pubkey".freeze
      PUBLIC_KEY_KEY = "key".freeze

      def initialize
        @error_messages = []
      end

      # Get public key from Monobank API
      #
      # @return [Boolean] true if key was successfully received, false otherwise
      def request_key
        begin
          response = RestClient.get(API_GET_KEY_URL, headers)
          response_body = JSON.parse(response.body)
          base64_key = JSON.parse(response.body)[PUBLIC_KEY_KEY]

          @key = Base64.decode64(base64_key)

          true
        rescue Exception => e
          # TODO: Check how for example Stripe or Liqpay handle errors
          response_body = JSON.parse(e.response.body)
          error_message = [e.message, response_body].join(", ")

          error_messages << error_message

          false
        end
      end
    end
  end
end
