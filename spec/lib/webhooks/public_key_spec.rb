# frozen_string_literal: true

RSpec.describe MonopayRuby::Webhooks::PublicKey do
  let(:response_example) { "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFQUc1LzZ3NnZubGJZb0ZmRHlYWE4vS29CbVVjTgo3NWJSUWg4MFBhaEdldnJoanFCQnI3OXNSS0JSbnpHODFUZVQ5OEFOakU1c0R3RmZ5Znhub0ZJcmZBPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==" }

  describe "#request_key" do
    context "when request is successful" do
      before do
        allow(RestClient).to receive(:get).and_return(double(body: { "key" => response_example }.to_json))
      end

      it "returns true" do
        expect(subject.request_key).to be_truthy
      end

      it "sets key" do
        expect { subject.request_key }.to change(subject, :key).from(nil).to(Base64.decode64(response_example))
      end
    end

    context "when request is failed" do
      context "with missing token" do
        let(:missing_x_token_server_message) { { "errorDescription" => "Missing required header 'X-Token'" } }
        let(:missing_x_token_client_message) { "400 Bad Request" }
        let(:missing_x_token_header_error_message) do
          [missing_x_token_client_message, missing_x_token_server_message].join(", ")
        end
        let(:exception_instance) do
          RestClient::ExceptionWithResponse.new(double(body: missing_x_token_server_message.to_json))
        end

        before do
          exception_instance.message = missing_x_token_client_message

          allow(RestClient).to receive(:get).and_raise(exception_instance)
        end

        it "returns false" do
          expect(subject.request_key).to be_falsey
        end

        it "has error message" do
          subject.request_key

          expect(subject.error_messages).to include(missing_x_token_header_error_message)
        end
      end

      context "with invalid token" do
        let(:invalid_token_server_message) { { "errorDescription" => "Unknown 'X-Token'" } }
        let(:invalid_token_client_message) { "403 Forbidden" }
        let(:invalid_token_error_message) { [invalid_token_client_message, invalid_token_server_message].join(", ") }
        let(:exception_instance) do
          RestClient::ExceptionWithResponse.new(double(body: invalid_token_server_message.to_json))
        end

        before do
          exception_instance.message = invalid_token_client_message

          allow(RestClient).to receive(:get).and_raise(exception_instance)
        end

        it "returns false" do
          expect(subject.request_key).to be_falsey
        end

        it "has error message" do
          subject.request_key

          expect(subject.error_messages).to include(invalid_token_error_message)
        end
      end
    end
  end
end
