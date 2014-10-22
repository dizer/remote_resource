require 'active_support/all'
require 'active_model'
require 'httparty'
require 'nokogiri'

require 'remote_resource/connection'
require 'remote_resource/document_wrapper'

require 'remote_resource/concerns'
require 'remote_resource/concerns/attributes'
require 'remote_resource/concerns/mappings'
require 'remote_resource/concerns/relation'


class RemoteResource::Model
  include ActiveModel::Model
  include RemoteResource::Concerns::Attributes
  include RemoteResource::Concerns::Relation
  include RemoteResource::Concerns::Mappings

  attr_accessor :url

  delegate_to_relation :path, :separate, :via, :unwrap, :limit
  delegate_to_relation_merged :query, :body, :cookies, :headers

  def connection
    self.class.connection
  end

  class << self
    def connection
      @connection ||= RemoteResource::Connection.new
    end
  end
end
