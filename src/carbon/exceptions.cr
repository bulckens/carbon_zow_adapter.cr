class Carbon::ZowAdapter < Carbon::Adapter
  class RequestException < Exception
    JSON.mapping({
      success: String?,
      error:   String?,
      details: Alias::DetailsHash?,
    })

    def message
      if error
        message = "Error: #{error}"
        if details
          messages = details.as(Alias::DetailsHash).map do |key, errors|
            %("#{key}" #{errors.values.join(", ")})
          end
          message = %(#{message}; #{messages.join(", ")})
        end
        message
      else
        "Success: #{success}"
      end
    end
  end
end
