class RemoteResource::Html::Connection < RemoteResource::Connection
  parser Proc.new { |body| Nokogiri::HTML(body) }
end
