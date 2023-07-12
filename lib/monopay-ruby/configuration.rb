class MonopayRuby::Configuration
  attr_accessor :api_token, :min_value

  def initialize
    @api_token = ENV["MONOBANK_API_TOKEN"] # note ability to use ENV variable in docs
    @min_value = ENV["MIN_VALUE"] || 1 # 0.01 - minimun valid amount in Monobank
  end
end
