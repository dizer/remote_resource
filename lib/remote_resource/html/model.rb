class RemoteResource::Html::Model < RemoteResource::Model
  class << self
    def connection
      @connection ||= RemoteResource::Html::Connection.new
    end
  end
end
