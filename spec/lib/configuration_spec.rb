# frozen_string_literal: true

RSpec.describe MonopayRuby::Configuration do
  describe "#api_token" do
    after do
      subject.api_token = nil
      ENV["MONOBANK_API_TOKEN"] = nil
    end

    it "returns api_token" do
      expect(subject.api_token).to eq(nil)
    end

    it "is configurable" do
      subject.api_token = "test"

      expect(subject.api_token).to eq("test")
    end

    it "is configurable via ENV variable" do
      ENV["MONOBANK_API_TOKEN"] = "test"

      expect(subject.api_token).to eq("test")
    end
  end
end
