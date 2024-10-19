# frozen_string_literal: true

RSpec.describe MonopayRuby::Invoices::AdvancedInvoice do
  describe "#new" do
    let!(:redirect_url) { "https://redirect.example.com" }
    let!(:webhook_url) { "https://webhook.example.com" }

    context "with keyword parameters" do
      subject { described_class.new(redirect_url: redirect_url, webhook_url: webhook_url) }

      it "initializes with correct redirect_url" do
        expect(subject.redirect_url).to eq(redirect_url)
      end

      it "initializes with correct webhook_url" do
        expect(subject.webhook_url).to eq(webhook_url)
      end
    end

    context "without keyword parameters" do
      subject { described_class.new(redirect_url, webhook_url) }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "without parameters" do
      subject { described_class.new }

      it { is_expected.to be_a(described_class) }
    end
  end

  describe "#create" do
    context "when request is successful" do
      let(:simple_invoice_instance) { described_class.new }
      let(:invoice_id) { "p2_9ZgpZVsl3" }
      let(:page_url) { "https://pay.mbnk.biz/p2_9ZgpZVsl3" }
      let(:basket_order) { { name: "product", qty: 1 } }
      let(:additional_params) { { merchantPaymInfo: { basketOrder: [basket_order] }, ccy: 9 } }
      let(:response_example) { { "invoiceId": invoice_id, "pageUrl": page_url } }

      before do
        allow(RestClient).to receive(:post).and_return(double(body: response_example.to_json))
      end

      it "returns true" do
        expect(simple_invoice_instance.create(2000, additional_params: additional_params)).to be_truthy
      end
    end
  end
end
