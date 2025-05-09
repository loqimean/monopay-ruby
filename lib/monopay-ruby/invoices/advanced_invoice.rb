require_relative "simple_invoice"

module MonopayRuby
  module Invoices
    class AdvancedInvoice < MonopayRuby::Invoices::SimpleInvoice
      using MonopayRuby::Extensions::BlankMethodExtension

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
        @destination = @additional_params.dig(:merchantPaymInfo, :destination)
        @reference = @additional_params.dig(:merchantPaymInfo, :reference)

        super(amount, destination: @destination, reference: @reference)
      end

      protected

      def request_body
        current_params = default_params

        return current_params.to_json if additional_params.blank?

        merge_merchant_payment_info!(current_params)
        current_params.merge!(additional_params.except(:merchantPaymInfo))

        update_sum_and_qty_params(current_params.dig(:merchantPaymInfo, :basketOrder))
        update_sum_and_qty_params(current_params[:items])

        current_params.to_json
      end

      # Merges merchant payment information into the current parameters.
      #
      # @param current_params [Hash] The current parameters to update.
      def merge_merchant_payment_info!(current_params)
        return if additional_params[:merchantPaymInfo].blank?

        current_params[:merchantPaymInfo] = {
          reference: @reference,
          destination: @destination
        }.merge!(additional_params[:merchantPaymInfo].except(:reference, :destination))
      end

      # Updates sum and quantity parameters for the given items.
      #
      # @param items [Array<Hash>] The items to update.
      def update_sum_and_qty_params(items)
        return if items.blank?

        items.each do |item|
          next if item.blank?

          item[:sum] = convert_to_cents(item[:sum] || amount)
          item[:qty] ||= 1
        end
      end
    end
  end
end
