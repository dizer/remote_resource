class RemoteResource::Json::Connection < RemoteResource::Connection
  parser Proc.new { |body| ActiveSupport::JSON.decode(body) }

  def default_options
    super.except(:logger)
  end
end
