class RemoteResource::Model::Relation

  attr_reader :model_class
  attr_accessor :attributes

  def initialize(model_class, attributes={})
    @model_class    = model_class
    self.attributes = attributes
  end

  def method_missing(meth, *args, &block)
    if model_class.delegated_to_relation.try(:include?, meth)
      if args.count > 0
        arg = if model_class.delegated_to_relation_merged.try(:include?, meth)
                (attributes[meth] || {}).merge(args.first)
              else
                args.first
              end
        self.class.for_model(model_class, attributes.merge(meth => arg))
      else
        attributes[meth]
      end

    elsif model_class.delegated_from_relation.try(:include?, meth)
      options = args.extract_options!
      model_class.send(meth, *args, options.merge(attributes), &block)
    else
      super
    end
  end

  def relation
    self
  end

  def all(options={})
    raise '`path` for query not specified' unless attributes[:path]
    results = model_class.connection.request(
        attributes[:path],
        separate:    attributes[:separate],
        http_method: attributes[:via],
        query:       attributes[:query],
        body:        attributes[:body],
        cookies:     attributes[:cookies],
        headers:     attributes[:headers],
        unwrap:      attributes[:unwrap],
    )
    results.take(attributes[:limit] || results.count).map do |result_row|
      build(result_row, options)
    end
  end

  def first(options={})
    limit(1).all(options).first
  end

  alias :find :first

  def build(doc, options={}, &block)
    model    = model_class.new(url: attributes[:path])
    document = RemoteResource::DocumentWrapper.new(doc)

    mapping_name = options[:mapping] || :default
    mapping  = model_class.mappings[mapping_name]
    raise "Mapping `#{mapping_name}` not found" unless mapping

    model.instance_exec(document, &mapping)
    instance_exec(model, &block) if block_given?
    model
  end

  def on_all_pages(all_options={}, &block)
    all_entities = []
    begin
      page            = (page || -1) + 1
      remaining_limit = attributes[:limit] ? attributes[:limit] - all_entities.count : nil
      entities        = block_given? ? instance_exec(page, &block) : limit(remaining_limit).page(page).all(all_options)
      all_entities    += entities if entities.any?
    end while entities.any?
    all_entities.compact
  end

  def on_pages(urls, all_options={})
    on_all_pages do |n|
      if urls[n]
        path(urls[n]).all(all_options)
      else
        []
      end
    end
  end

  def self.for_model(model, attributes={})
    rel = RemoteResource::Model::Relation.new(model, attributes)
    rel.send(:extend, "#{model.name}::RelationMethods".constantize) if model.const_defined?(:RelationMethods)
    rel
  end

end
