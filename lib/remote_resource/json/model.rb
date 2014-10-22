class RemoteResource::Json::Model < RemoteResource::Model
  class << self
    def connection
      @connection ||= RemoteResource::Json::Connection.new
    end
  end
end
