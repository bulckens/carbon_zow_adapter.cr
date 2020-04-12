require "../../spec_helper"

describe Carbon::ZowAdapter do
  describe ".deliver_now" do
    it "delivers the email successfully" do
      WebMock.stub(:post, "https://mailer.zwartopwit.be/api/v1/zwartopwit_dev/mails.json")
        .to_return(body: %({"success":"mail.created","mail":{"to":"a@b.c","from":"d@e.f","subject":"Hello World","language":"en","text":"Hello, World!","entity_id":1,"updated_at":"2017-10-15 12:51:18","created_at":"2017-10-15 12:51:18","id":2},"current_entity":{"id":1,"key":"zwartopwit","created_at":"2017-10-13 12:51:18","updated_at":"2017-10-13 12:51:18"}}))

      send_email_to_zow_mailer text_body: "text template",
        to: [Carbon::Address.new("w@zwartopwit.be")]
    end

    pending "delivers emails with reply_to set" do
      send_email_to_zow_mailer text_body: "text template",
        to: [Carbon::Address.new("w@zwartopwit.be")],
        headers: {"Reply-To" => "noreply@zwartopwit.be"}
    end
  end

  describe ".deliver_later" do
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

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  Carbon::ZowAdapter::Email.new(email, "fake_entity", "fake_secret").params
end

private def send_email_to_zow_mailer(**email_attrs)
  secret = ENV.fetch("ZOW_MAILER_SECRET")
  entity = ENV.fetch("ZOW_MAILER_ENTITY")
  email = FakeEmail.new(**email_attrs)
  adapter = Carbon::ZowAdapter.new(entity: entity, secret: secret)
  adapter.deliver_now(email)
end
