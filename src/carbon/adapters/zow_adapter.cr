class Carbon::ZowAdapter < Carbon::Adapter
  private getter entity : String
  private getter secret : String
  private getter language : String

  def initialize(
    @entity : String,
    @secret : String,
    @language : String = "en"
  )
  end

  def deliver_now(email : Carbon::Email)
    email_instance(email).deliver
  end

  def deliver_at(email : Carbon::Email, time : Time)
    email_instance(email).send_at(time).deliver
  end

  private def email_instance(email : Carbon::Email)
    Email.new(email, entity, secret, language)
  end

  class Email
    BASE_URI         = "mailer.zwartopwit.be"
    BASE_API_PATH    = "/api/v1"
    CREATE_MAIL_PATH = "/mails.json"

    private getter email, entity, secret, language
    private getter send_at : Time? = nil

    def initialize(
      @email : Carbon::Email,
      @entity : String,
      @secret : String,
      @language : String = "en"
    )
    end

    def send_at(time : Time) : Email
      @send_at = time
      self
    end

    def deliver
      client.post(endpoint, body: params.to_json).tap do |response|
        unless response.success?
          raise RequestException.from_json(response.body)
        end
      end
    end

    def params
      {
        mail: {
          to:       address_to_string(email.to),
          cc:       address_to_string(email.cc),
          bcc:      address_to_string(email.bcc),
          from:     email.from.to_s,
          reply:    reply_to,
          subject:  email.subject,
          language: language,
          html:     email.html_body,
          text:     email.text_body,
          send_at:  send_at,
        },
      }
    end

    private def address_to_string(addresses : Array(Carbon::Address))
      addresses.map(&.to_s).join(",")
    end

    private def reply_to : String?
      email.headers.select { |key, _| key.downcase == "reply-to" }.values.first?
    end

    private def endpoint
      "#{BASE_API_PATH}/#{@entity}#{CREATE_MAIL_PATH}"
    end

    private def token
      ZowToken.generate(endpoint, secret)
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(BASE_URI, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          request.headers["Authentication"] = "Bearer #{token}"
          request.headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
