module RemoteResource::Concerns::Mappings
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :mappings
    end
  end

  module ClassMethods
    def mapping(name = :default, &block)
      @mappings ||= {}
      @mappings[name] = block
    end
  end
end
