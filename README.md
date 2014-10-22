# RemoteResource



## Remote::Html::Model
Object interface over remote HTML (and JSON) resources.

### Example

For example you have ```http://example.com/companies/a``` with this content:

```html
<html>
    <body>
        <h1>Company A</h1>
        <div class="desc">Lovely company</div>
    </body>
</html>
```

First, define Company model:

```ruby
class Company < RemoteResource::Html::Model
  attr_accessor :name, :description

  mapping do |doc|
    self.name        = doc.c('h1')
    self.description = doc.c('.desc')
  end
end
```

Now you can make requests:

```ruby
company = Company.path('http://example.com/companies/a').find
company.name        # => "Company A"
company.description # => "Lovely company"
```

#### Document maps

```mapping``` describes how to get attributes from html:

```ruby
class Company < RemoteResource::Html::Model
  attr_accessor :name, :description
    
  mapping do |doc|
    self.name        = doc.c('h1')
    self.description = doc.c('.desc')
  end
    
  mapping :fake_name do |doc|
    self.name        = 'Fake'
    self.description = doc.c('.desc')
  end
end

company = Company.path('http://example.com/companies/a').find(:fake_name)
company.name        # => "Fake"
company.description # => "Lovely company"
```

##### Helpers

Inside document_map you can use special helpers:

```ruby
c(selector)            # Get content of html node by css selector
a(attribute, selector) # Get tag attribute by css selector
parse_date(string)     # Get date, uses chronic gem to parse complex dates
```

#### Collections

.find (and its alias .first) returns only first occurrence, meanwhile .all returns Array of all elements.
```http://example.com/companies```:

```html
<html>
    <body>
        <div class="company">
            <h1>Company A</h1>
            <div class="desc">Lovely company</div>
        </div>
        <div class="company">
            <h1>Company B</h1>
            <div class="desc">Worst company ever</div>
        </div>
    </body>
</html>
```

Collection of companies:

```ruby
companies = Company.path('http://example.com/companies').separate(css: '.company').all # => [<Company...>, <Company...>]
companies.first.name # => "Company A"
companies.last.name  # => "Company B"
```

##### Pagination example
Pagination can be performed with multiple ways, for example: 

```ruby
class Company < RemoteResource::Html::Model
  # ...
  module RelationMethods
    def page(n)
      query(limit: 100, offset: n.to_i * 100)
    end
  end
end

Company.path('http://example.com/companies').page(0).all
# will perform request to http://example.com/companies?limit=100&offset=0
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'remote_resource'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remote_resource

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remote_resource/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
