require 'remote_resource/concerns/party_query'

class RemoteResource::Connection
  include RemoteResource::PartyQuery

  def request(path, options={})
    separate = options[:separate]

    if options[:unwrap]
      original_parser  = self.class.parser
      options[:parser] = Proc.new { |body|
        body = options[:unwrap].call(body)
        original_parser.call(body)
      }
    end

    result = query(path, options)
    Array.wrap(
        if separate.try(:[], :json)
          separate[:json].inject(result) { |r, p| r.try(:[], p.to_s) }
        elsif separate.try(:[], :css)
          result.css(separate[:css])
        else
          result
        end
    )
  end
end
