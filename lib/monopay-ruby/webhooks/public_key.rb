module MonopayRuby
  module Webhooks
    class PublicKey < MonopayRuby::Base
      attr_reader :status, :error_messages, :key

      API_GET_KEY_URL = "#{API_URL}/merchant/pubkey".freeze
      PUBLIC_KEY_KEY = "key".freeze

      # Get public key from Monobank API
      #
      # @return [String] public key or error message if failed
      def request_key
        begin
          response = RestClient.get(API_GET_KEY_URL, headers)
          response_body = JSON.parse(response.body)
          base64_key = JSON.parse(response.body)[PUBLIC_KEY_KEY]
          @status = SUCCESS

          @key = Base64.decode64(base64_key)
        rescue Exception => e
          # TODO: Check how for example Stripe or Liqpay handle errors
          @status = FAILURE
          @error_messages << [e.message, e.response.body].join(", ")
        end
      end
    end
  end
end
