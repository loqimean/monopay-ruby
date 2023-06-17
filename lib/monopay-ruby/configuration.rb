class MonopayRuby::Configuration
  attr_accessor :api_token

  def initialize
    @api_token = ENV["MONOBANK_API_TOKEN"] # note ability to use ENV variable in docs
  end
end
