module RemoteResource::Concerns::Relation
  extend ActiveSupport::Concern

  included do
    extend SingleForwardable
  end

  module ClassMethods
    def relation
      @relation ||= RemoteResource::Model::Relation.for_model(self)
    end

    def delegate_to_relation(*methods)
      @delegated_to_relation ||= []
      @delegated_to_relation += methods
      single_delegate methods => :relation
    end

    def delegated_to_relation
      collect_from_superclasses(:@delegated_to_relation)
    end

    def delegate_to_relation_merged(*methods)
      @delegated_to_relation_merged ||= []
      @delegated_to_relation_merged += methods
      delegate_to_relation(*methods)
    end

    def delegated_to_relation_merged
      collect_from_superclasses(:@delegated_to_relation_merged)
    end

    def delegate_from_relation(*methods)
      @delegated_from_relation ||= []
      @delegated_from_relation += methods
    end

    def delegated_from_relation
      collect_from_superclasses(:@delegated_from_relation)
    end

    def collect_from_superclasses(variable_name)
      methods = []
      klass = self
      while klass do
        methods += Array.wrap(klass.instance_variable_get(variable_name))
        klass = klass.superclass
      end
      methods
    end
  end
end
