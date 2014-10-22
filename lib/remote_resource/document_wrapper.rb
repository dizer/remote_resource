class RemoteResource::DocumentWrapper < SimpleDelegator
  def css_content(selector)
    selected = at_css(selector).try(:clone)
    return unless selected
    selected.css('br').each{ |br| br.replace "\n" }
    selected.try(:content).to_s.strip
  end

  alias :c :css_content

  def tag_attribute(attribute, selector)
    at_css(selector).try(:[], attribute).to_s
  end

  alias :a :tag_attribute

  def css_self_content(selector)
    at_css(selector).try(:xpath, 'text()').to_s.strip
  end

  alias :c_self :css_self_content

  def parse_date(date, options={})
    if options.any? && options.delete(:chronic) != false
      require 'chronic'
      Chronic.parse(date.to_s, {guess: :begin, context: :past}.merge(options))
    else
      begin
        Time.zone.parse(date.to_s)
      rescue ArgumentError
        nil
      end
    end
  end

  # abs_url('http://example.com', 'path?param=1')
  # => 'http://example.com/path?param=1'
  #
  # abs_url('ftp://sub.domain.dev/other_path?other_param=2', 'path?param=1#anchor')
  # => 'ftp://sub.domain.dev/path?param=1#anchor'
  def abs_url(base, path)
    abs = URI(base)
    rel = URI(path)
    rel.scheme = abs.scheme
    rel.host   = abs.host
    rel.to_s
  end
end
