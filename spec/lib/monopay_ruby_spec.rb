# frozen_string_literal: true

RSpec.describe MonopayRuby do
  it "has a version number" do
    expect(MonopayRuby::VERSION).not_to be nil
  end

  describe "#configuration" do
    it "returns configuration object" do
      expect(MonopayRuby.configuration).to be_a(MonopayRuby::Configuration)
    end

    it "is configurable" do
      expect do
        MonopayRuby.configure do |config|
          config.api_token = "test"
        end
      end.to change(MonopayRuby.configuration, :api_token).from(nil).to("test")
    end
  end
end
