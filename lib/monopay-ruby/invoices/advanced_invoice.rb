require_relative 'simple_invoice'
require 'active_support/all'

module MonopayRuby
  module Invoices
    class AdvancedInvoice < MonopayRuby::Invoices::SimpleInvoice
      attr_reader :additional_params, :amount

      # Create invoice for Monobank API
      #
      # This method sets up the required instance variables and then calls the `create`
      # method from the parent class with the relevant parameters.
      #
      # @param amount [Numeric] The amount of the payment.
      # @param additional_params [Hash] (optional) Additional parameters for the payment.
      #   - :merchantPaymInfo [Hash] Information about the merchant payment.
      #     - :destination [String] The destination of the payment.
      #     - :reference [String] A reference for the payment.
      #
      # @return [Boolean] The result of the `create` method in the parent class,
      #   which returns true if invoice was created successfully, false otherwise
      #
      # @example Create a payment with amount and additional parameters
      #   create(100, additional_params: { merchantPaymInfo: { destination: "Happy payment", reference: "ref123" } })
      def create(amount, additional_params: {})
        @amount = amount
        @additional_params = additional_params
        @destination = @additional_params&.dig(:merchantPaymInfo, :destination)
        @reference = @additional_params&.dig(:merchantPaymInfo, :reference)

        super(amount, destination: @destination, reference: @reference)
      end

      protected

      def request_body
        current_params = default_params

        return current_params.to_json if additional_params.blank?

        unless additional_params[:merchantPaymInfo].blank?
          current_params[:merchantPaymInfo] = {
              reference: @reference,
              destination: @destination
            }.merge!(additional_params[:merchantPaymInfo].except(:reference, :destination))
        end

        current_params.merge!(additional_params.except(:merchantPaymInfo))

        # It adds and modifies sum and qty params of merchantPaymInfo[basketOrder] parameters if it is present
        # It adds and modifies sum and qty params of items parameters if it is present
        set_sum_and_qty_params(current_params&.dig(:merchantPaymInfo, :basketOrder))
        set_sum_and_qty_params(current_params[:items])

        current_params.to_json
      end

      # Set sum and qty params
      # @param current_param [Array] The current parameter to set sum and qty
      # It sets the converted amount or sum parameter as sum and pasted quantity parameter or default value as qty parameters for the current parameter
      # @return [Object] It could be Hash or Array or nil. It depends on the current parameter
      def set_sum_and_qty_params(current_param)
        return if current_param.blank?

        current_param.each do |item|
          return if item.blank?

          item[:sum] = convert_to_cents(item[:sum] || amount)
          item[:qty] = item[:qty] || 1
        end
      end
    end
  end
end
