class Carbon::ZowAdapter < Carbon::Adapter
  class RequestException < Exception
    delegate error, success, details, to: @mapper

    def initialize(@mapper : Mapper)
    end

    def self.from_json(json : String)
      new(Mapper.from_json(json))
    end

    def message
      return "Success: #{success}" if success

      error_with_details
    end

    private def error_with_details : String
      String.build do |io|
        io << "Error: "
        io << error

        if details_hash = details
          io << "; "
          details_hash.each.with_index do |(key, errors), i|
            io << ", " unless i == 0
            io << "\""
            io << key
            io << "\" "
            io << errors.values.join(", ")
          end
        end
      end
    end

    struct Mapper
      include JSON::Serializable

      getter success : String?
      getter error : String?
      getter details : DetailsHash?
    end
  end
end
