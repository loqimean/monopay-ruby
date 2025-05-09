# frozen_string_literal: true

begin
  require "pry"
rescue LoadError
end

module MonopayRuby
  class Base
    API_URL = "https://api.monobank.ua/api".freeze

    protected

    # Required headers for Monobank API
    #
    # @return [Hash] headers
    def headers
      {
        content_type: :json,
        accept: :json,
        "X-Token": MonopayRuby.configuration.api_token
      }
    end
  end

  def self.configuration
    @configuration ||= MonopayRuby::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

Dir.glob(File.join(__dir__, "monopay-ruby", "/**/*.rb")).sort.each { |file| require file }
