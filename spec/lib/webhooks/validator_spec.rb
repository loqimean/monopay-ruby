# frozen_string_literal: true

RSpec.describe MonopayRuby::Webhooks::Validator do
  let(:signature) { "MEUCIQC/mVKhi8FKoayul2Mim3E2oaIOCNJk5dEXxTqbkeJSOQIgOM0hsW0qcP2H8iXy1aQYpmY0SJWEaWur7nQXlKDCFxA=" }
  let(:pub_key) { Base64.decode64("LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFQUc1LzZ3NnZubGJZb0ZmRHlYWE4vS29CbVVjTgo3NWJSUWg4MFBhaEdldnJoanFCQnI3OXNSS0JSbnpHODFUZVQ5OEFOakU1c0R3RmZ5Znhub0ZJcmZBPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==") }
  let(:webhook_data) do
    <<~JS.chomp
      {
        "invoiceId": "p2_9ZgpZVsl3",
        "status": "created",
        "failureReason": "string",
        "amount": 4200,
        "ccy": 980,
        "finalAmount": 4200,
        "createdDate": "2019-08-24T14:15:22Z",
        "modifiedDate": "2019-08-24T14:15:22Z",
        "reference": "84d0070ee4e44667b31371d8f8813947",
        "cancelList": [
          {
            "status": "processing",
            "amount": 4200,
            "ccy": 980,
            "createdDate": "2019-08-24T14:15:22Z",
            "modifiedDate": "2019-08-24T14:15:22Z",
            "approvalCode": "662476",
            "rrn": "060189181768",
            "extRef": "635ace02599849e981b2cd7a65f417fe"
          }
        ]
      }
    JS
  end
  let(:request) { double(raw_post: webhook_data, headers: { "X-Sign" => signature }) }

  describe "#valid?" do
    context "when webhook is authorized" do
      before do
        allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:request_key).and_return(true)
        allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:key).and_return(pub_key)
      end

      it "returns true" do
        expect(described_class.new(request).valid?).to eq(true)
      end
    end

    context "when webhook is not authorized" do
      context "with invalid signature" do
        let(:signature) { "MEUCIQC/mVKhi9FKoayul2Mim3E2oaIOCNJk5dEXxTqbkeJSOQIgOM0hsW0qcP2H8iXy1aQYpmY0SJWEaWur7nQXlKDCFxA=" }
        let(:validator_instance) { described_class.new(request) }

        before do
          allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:request_key).and_return(true)
          allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:key).and_return(pub_key)
        end

        it "returns false" do
          expect(validator_instance.valid?).to eq(false)
        end

        it "has error message" do
          validator_instance.valid?

          expect(validator_instance.error_messages).to include(
            "Webhook aren't authorized. Might be signature is invalid or webhook data is modified."
          )
        end
      end

      context "with missing token" do
        let(:missing_x_token_server_message) { { "errorDescription" => "Missing required header 'X-Token'" } }
        let(:missing_x_token_client_message) { "400 Bad Request" }
        let(:missing_x_token_header_error_message) do
          [missing_x_token_client_message, missing_x_token_server_message].join(", ")
        end
        let(:validator_instance) { described_class.new(request) }

        before do
          allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:request_key).and_return(false)
          allow_any_instance_of(MonopayRuby::Webhooks::PublicKey).to receive(:error_messages).and_return(missing_x_token_header_error_message)
        end

        it "returns false" do
          expect(validator_instance.valid?).to be_falsey
        end

        it "has error message" do
          validator_instance.valid?

          expect(validator_instance.error_messages).to include(missing_x_token_header_error_message)
        end
      end
    end
  end
end
