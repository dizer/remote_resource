module RemoteResource::Concerns::Attributes
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Serialization
  end

  def attributes
    self.class.attributes
  end

  def to_localone_hash
    serializable_hash
  end

  module ClassMethods
    def attr_accessor(*vars)
      @attributes = (@attributes || []) + vars
      super
    end

    def attributes
      Hash[(@attributes || []).map{|e| [e, nil]}]
    end
  end
end
