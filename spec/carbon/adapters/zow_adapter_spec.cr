require "../../spec_helper"

describe Carbon::ZowAdapter do
  describe ".deliver_now" do
    it "delivers the email successfully" do
      WebMock.stub(:post, "https://mailer.zwartopwit.be/api/v1/test_entity/mails.json")
        .to_return(body: %({"success":"mail.created"}))

      send_email_to_zow_mailer text_body: "text template",
        to: [Carbon::Address.new("w@zwartopwit.be")]
    end

    it "delivers emails with reply_to set" do
      WebMock.stub(:post, "https://mailer.zwartopwit.be/api/v1/test_entity/mails.json")
        .to_return(body: %({"success":"mail.created"}))

      send_email_to_zow_mailer text_body: "text template",
        to: [Carbon::Address.new("w@zwartopwit.be")],
        headers: {"Reply-To" => "noreply@zwartopwit.be"}
    end

    it "raises an error when data is missing" do
      WebMock.stub(:post, "https://mailer.zwartopwit.be/api/v1/test_entity/mails.json")
        .to_return(status: 422, body: %({"error":"mail.invalid"}))

      expect_raises(Carbon::ZowAdapter::RequestException) do
        send_email_to_zow_mailer text_body: "text template",
          to: [] of Carbon::Address
      end
    end
  end

  describe ".deliver_later" do
    it "delivers the email successfully later" do
      WebMock.stub(:post, "https://mailer.zwartopwit.be/api/v1/test_entity/mails.json")
        .to_return(body: %({"success":"mail.created"}))

      send_email_to_zow_mailer_later text_body: "text template",
        to: [Carbon::Address.new("w@zwartopwit.be")]
    end
  end

  describe Carbon::ZowAdapter::Email do
    describe "#params" do
      it "extratcs the reply to header" do
        headers = {"reply-to" => "noreply@badsupport.com", "Header" => "value"}
        params = params_for(headers: headers)

        params[:mail][:reply].should eq("noreply@badsupport.com")
      end

      it "extracts the reply to header regardless of case" do
        headers = {"Reply-To" => "noreply@badsupport.com", "Header" => "value"}
        params = params_for(headers: headers)

        params[:mail][:reply].should eq("noreply@badsupport.com")
      end

      it "sets the recipients" do
        to_without_name = Carbon::Address.new("to@example.com")
        to_with_name = Carbon::Address.new("Jimmy", "to2@example.com")
        cc_without_name = Carbon::Address.new("cc@example.com")
        cc_with_name = Carbon::Address.new("Kim", "cc2@example.com")
        bcc_without_name = Carbon::Address.new("bcc@example.com")
        bcc_with_name = Carbon::Address.new("James", "bcc2@example.com")

        recipient_params = params_for(
          to: [to_without_name, to_with_name],
          cc: [cc_without_name, cc_with_name],
          bcc: [bcc_without_name, bcc_with_name]
        )

        recipient_params[:mail][:to]
          .should eq(%(to@example.com,"Jimmy" <to2@example.com>))
        recipient_params[:mail][:cc]
          .should eq(%(cc@example.com,"Kim" <cc2@example.com>))
        recipient_params[:mail][:bcc]
          .should eq(%(bcc@example.com,"James" <bcc2@example.com>))
      end

      it "sets the subject" do
        params_for(subject: "My subject")[:mail][:subject].should eq "My subject"
      end

      it "sets the from address" do
        address = Carbon::Address.new("from@example.com")
        params_for(from: address)[:mail][:from]
          .should eq("from@example.com")

        address = Carbon::Address.new("Sally", "from@example.com")
        params_for(from: address)[:mail][:from]
          .should eq(%("Sally" <from@example.com>))
      end

      it "sets the content" do
        params_for(text_body: "Simply text.")[:mail][:text]
          .should eq("Simply text.")
        params_for(html_body: "Fancy <b>html</b>!")[:mail][:html]
          .should eq("Fancy <b>html</b>!")
      end
    end
  end
end

private def test_entity
  "test_entity"
end

private def test_secret
  "supersecret"
end

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  Carbon::ZowAdapter::Email.new(email, test_entity, test_secret).params
end

private def send_email_to_zow_mailer(**email_attrs)
  prepare_adapter.deliver_now(prepare_email(**email_attrs))
end

private def send_email_to_zow_mailer_later(**email_attrs)
  prepare_adapter.deliver_at(prepare_email(**email_attrs), Time.local)
end

private def prepare_adapter
  Carbon::ZowAdapter.new(entity: test_entity, secret: test_secret)
end

private def prepare_email(**email_attrs)
  FakeEmail.new(**email_attrs)
end
