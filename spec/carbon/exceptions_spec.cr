require "../spec_helper"

describe Carbon::ZowAdapter::RequestException do
  describe ".from_json" do
    it "parses an optional error message" do
      exception = test_exception(%({"error" : "mail.invalid"}))
      exception.error.should eq("mail.invalid")
    end

    it "parses an optional success message" do
      exception = test_exception(%({"success" : "mail.created"}))
      exception.success.should eq("mail.created")
    end

    it "parses optional details" do
      exception = test_exception(%({
        "error" : "mail.invalid",
        "details" : {
          "to" : {
            "required" : "is required"
          }
        }
      }))
      details = exception.details.as(Carbon::ZowAdapter::Alias::DetailsHash)
      details["to"]["required"].should eq("is required")
    end
  end

  describe "#message" do
    it "returns a success message" do
      exception = test_exception(%({"success" : "status.200"}))
      exception.message.should eq("Success: status.200")
    end

    it "returns an error message" do
      exception = test_exception(%({"error" : "mail.invalid"}))
      exception.message.should eq("Error: mail.invalid")
    end

    it "composes a readable error message" do
      exception = test_exception(%({
        "error" : "mail.invalid",
        "details" : {
          "to" : {
            "required" : "is required"
          },
          "from" : {
            "required" : "is required"
          },
          "subject" : {
            "required" : "is required"
          }
        }
      }))
      exception.message
        .should eq(%(Error: mail.invalid; "to" is required, "from" is required, "subject" is required))
    end
  end
end

private def test_exception(json : String)
  Carbon::ZowAdapter::RequestException.from_json(json)
end
