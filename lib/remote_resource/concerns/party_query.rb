module RemoteResource::PartyQuery
  extend ActiveSupport::Concern

  included do
    include HTTParty
  end

  def query(path, options={})
    result = nil
    query_options = default_options.deep_merge(options.compact)
    time = Benchmark.ms do
      response = case options.delete(:http_method)
                 when :post
                   post(path, query_options)
                 else
                   get(path, query_options)
                 end
      raise ResponseException.new(response.code, response) if response.code != 200
      result = response.parsed_response
    end
    result
  ensure
    logger.debug "(#{time.try(:round, 1) || 'Failed'} ms) #{path} opts: #{query_options.except(:logger, :log_level, :log_format)}" if logger
  end

  class ResponseException < StandardError
    attr_accessor :code
    def initialize(code, msg, &block)
      @code = code
      super(["HTTP code: #{code}", msg].join('. '), &block)
    end
  end

protected

  def default_options
    {
        headers: {
            'User-Agent'      => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36',
            'Accept-Language' => 'en-US,en;q=0.8',
        },
        logger: logger,
        log_format: :apache
    }
  end

  def get(path, options={}, &block)
    self.class.get(path, options, &block)
  end

  def post(path, options={}, &block)
    self.class.post(path, options, &block)
  end

  def logger
    defined?(Rails) ? Rails.logger : nil
  end

  def debug?
    false
  end
end
