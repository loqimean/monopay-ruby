class MonopayRuby::Configuration
  attr_accessor :api_token, :min_price

  def initialize
    @api_token = ENV["MONOBANK_API_TOKEN"]
    @min_price = ENV["MIN_PRICE"] || 1
  end
end
