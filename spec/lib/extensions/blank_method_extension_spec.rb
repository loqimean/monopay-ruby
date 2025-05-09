# frozen_string_literal: true

RSpec.describe MonopayRuby::Extensions::BlankMethodExtension do
  using described_class

  describe "#blank?" do
    context "when the object is nil" do
      it "returns true" do
        expect(nil.blank?).to eq(true)
      end
    end

    context "when the object is an empty string" do
      it "returns true" do
        expect("".blank?).to eq(true)
      end
    end

    context "when the object is a string with only spaces" do
      it "returns true" do
        expect("   ".blank?).to eq(true)
      end
    end

    context "when the object is a non-empty string" do
      it "returns false" do
        expect("hello".blank?).to eq(false)
      end
    end

    context "when the object is an empty array" do
      it "returns true" do
        expect([].blank?).to eq(true)
      end
    end

    context "when the object is a non-empty array" do
      it "returns false" do
        expect([1, 2, 3].blank?).to eq(false)
      end
    end

    context "when the object is an empty hash" do
      it "returns true" do
        expect({}.blank?).to eq(true)
      end
    end

    context "when the object is a non-empty hash" do
      it "returns false" do
        expect({ key: "value" }.blank?).to eq(false)
      end
    end
  end

  describe "#present?" do
    context "when the object is nil" do
      it "returns false" do
        expect(nil.present?).to eq(false)
      end
    end

    context "when the object is an empty string" do
      it "returns false" do
        expect("".present?).to eq(false)
      end
    end

    context "when the object is a string with only spaces" do
      it "returns false" do
        expect("   ".present?).to eq(false)
      end
    end

    context "when the object is a non-empty string" do
      it "returns true" do
        expect("hello".present?).to eq(true)
      end
    end

    context "when the object is an empty array" do
      it "returns false" do
        expect([].present?).to eq(false)
      end
    end

    context "when the object is a non-empty array" do
      it "returns true" do
        expect([1, 2, 3].present?).to eq(true)
      end
    end

    context "when the object is an empty hash" do
      it "returns false" do
        expect({}.present?).to eq(false)
      end
    end

    context "when the object is a non-empty hash" do
      it "returns true" do
        expect({ key: "value" }.present?).to eq(true)
      end
    end
  end
end
