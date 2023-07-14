class MonopayRuby::Configuration
  attr_accessor :api_token, :min_value

  def initialize
    @api_token = ENV["MONOBANK_API_TOKEN"]
    @min_value = ENV["MIN_VALUE"] || 1
  end
end
