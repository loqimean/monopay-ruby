module MonopayRuby
  module Webhooks
    class Validator
      attr_reader :error_messages

      # Initialize service
      #
      # @param [ActionDispatch::Request] request
      # @example Usage
      # class SomeController < ApplicationController
      #   skip_before_action :verify_authenticity_token, only: [:webhook]
      #
      #   def webhook
      #     validator = MonopayRuby::Webhooks::Validator.new(request)
      #
      #     if validator.valid?
      #       # do something with webhook data
      #
      #       head :ok
      #     else
      #       flash[:error] = validator.error_messages.join(", ")
      #
      #       # do something
      #
      #        head :unprocessable_entity
      #     end
      #   end
      # end
      def initialize(request)
        @request = request
        @webhook_data = @request.raw_post
        # @key = Rails.cache.fetch(:monobank_webhook_key) do
        #   Monobank::Webhooks::KeyService.new.key
        # end
        @public_key_service = MonopayRuby::Webhooks::PublicKey.new

        @error_messages = []
      end

      # Validate webhook data signature with public key
      #
      # @return [Boolean] true if valid, false if not valid
      def valid?
        return false if @webhook_data.nil?
        return false if signature.nil?

        if @public_key_service.request_key
          @public_key ||= @public_key_service.key

          openssl_ec = OpenSSL::PKey::EC.new(@public_key)
          openssl_ec.check_key

          return true if openssl_ec.verify(digest, signature, @webhook_data)

          @error_messages << "Webhook aren't authorized. Might be signature is invalid or webhook data is modified."
        else
          @error_messages << @public_key_service.error_messages
        end

        false
      end

      private

      # Get signature from request headers
      #
      # @return [String] signature
      def signature
        @signature ||= Base64.decode64(@request.headers["X-Sign"])
      end

      # Get digest from OpenSSL
      #
      # @return [OpenSSL::Digest] digest
      def digest
        @digest ||= OpenSSL::Digest.new("SHA256")
      end
    end
  end
end
