# frozen_string_literal: true

RSpec.describe MonopayRuby::Invoices::SimpleInvoice do
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
      let(:response_example) { { "invoiceId": invoice_id, "pageUrl": page_url } }

      before do
        allow(RestClient).to receive(:post).and_return(double(body: response_example.to_json))
      end

      it "returns true" do
        expect(simple_invoice_instance.create(2000)).to be_truthy
      end

      it "sets invoice_id" do
        expect do
          simple_invoice_instance.create(2000)
        end.to change(simple_invoice_instance, :invoice_id).from(nil).to(invoice_id)
      end

      it "sets page_url" do
        expect do
          simple_invoice_instance.create(2000)
        end.to change(simple_invoice_instance, :page_url).from(nil).to(page_url)
      end

      context "when amount is BigDecimal" do
        it "sets amount" do
          expect do
            simple_invoice_instance.create(BigDecimal("20"))
          end.to change(simple_invoice_instance, :amount).from(nil).to(2000)
        end
      end
    end

    context "when request is failed" do
      context "with missing token" do
        # move this code to shared example or mb shared context
        let(:missing_x_token_server_message) {
          {
            "errCode" => "BAD_REQUEST",
            "errText" => "Missing required header 'X-Token'",
            "errorDescription" => "Missing required header 'X-Token'"
          }
        }
        let(:error_code) { "400 Bad Request" }
        let(:missing_x_token_header_error_message) do
          [error_code, missing_x_token_server_message].join(", ")
        end
        let(:exception_instance) do
          RestClient::ExceptionWithResponse.new(double(body: missing_x_token_server_message.to_json))
        end

        before do
          exception_instance.message = error_code

          allow(RestClient).to receive(:get).and_raise(exception_instance)
        end

        it "returns false" do
          expect(subject.create(2000)).to be_falsey
        end

        it "has error message" do
          subject.create(2000)

          expect(subject.error_messages).to include(missing_x_token_header_error_message)
        end
      end

      context "with invalid token" do
        # TODO: move this code to shared example or mb shared context
        let(:invalid_token_server_message) { { "errorDescription" => "Unknown 'X-Token'" } }
        let(:error_code) { "403 Forbidden" }
        let(:invalid_token_error_message) { [error_code, invalid_token_server_message].join(", ") }
        let(:exception_instance) do
          RestClient::ExceptionWithResponse.new(double(body: invalid_token_server_message.to_json))
        end

        before do
          exception_instance.message = error_code

          allow(RestClient).to receive(:post).and_raise(exception_instance)
          allow_any_instance_of(described_class).to receive(:headers).and_return("X-Token" => "invalid_token")
        end

        it "returns false" do
          expect(subject.create(2000)).to be_falsey
        end

        it "has error message" do
          subject.create(2000)

          expect(subject.error_messages).to include(invalid_token_error_message)
        end
      end

      context "with invalid params" do
        let(:invalid_amount_server_error_message) { { "errCode" => "BAD_REQUEST", "errText" => "json unmarshal: : json: cannot unmarshal string into Go struct field InvoiceCreateRequest.amount of type int64" } }
        let(:error_code) { "400 Bad Request" }
        let(:invalid_amount_error_message) do
          [error_code, invalid_amount_server_error_message].join(", ")
        end
        let(:exception_instance) do
          RestClient::ExceptionWithResponse.new(double(body: invalid_amount_server_error_message.to_json))
        end

        before do
          exception_instance.message = error_code

          allow(RestClient).to receive(:post).and_raise(exception_instance)
        end

        it "returns false" do
          expect(subject.create("")).to be_falsey
        end

        it "has error message" do
          subject.create("")

          expect(subject.error_messages).to include(invalid_amount_error_message)
        end
      end
    end
  end
end
