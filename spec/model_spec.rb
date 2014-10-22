require 'spec_helper'

module TestCase
  class Company < RemoteResource::Html::Model
    attr_accessor :name

    mapping do |document|
      self.name = document.c('h1')
    end
  end

  class User < RemoteResource::Html::Model
    attr_accessor :name, :link

    mapping do |document|
      self.name = document.c('a')
      self.link = document.a('href', 'a')
    end

    mapping :only_name do |document|
      self.name = document.c('a')
    end
  end
end

describe RemoteResource::Html::Model do

  let(:url) { 'http://example.com/companies/a' }
  let(:query) { TestCase::User.path(url).separate(css: 'li') }

  before do
    stub_request(:get, url).
        to_return(status: 200, body: '
          <body>
            <h1>Company A</h1>
            <ul class="users">
              <li><a href="users/1">User 1</a></li>
              <li><a href="users/2">User 2</a></li>
            </ul>
          </body>'
    )
  end

  context '#all' do
    subject { query.all }

    it do
      expect(subject).to all(be_instance_of(TestCase::User))
    end

    it do
      expect(subject.count).to eq(2)
    end

    context 'instance' do
      let(:user) { subject.first }
      it do
        expect(user.name).to eq('User 1')
        expect(user.link).to eq('users/1')
      end
    end

    context 'another mapping' do
      it do
        expect(query.all(mapping: :only_name)).to all(be_instance_of(TestCase::User))
        expect(query.all(mapping: :only_name).count).to eq(2)
      end

      context 'instance' do
        let(:user) { query.first(mapping: :only_name) }
        it do
          expect(user.name).to eq('User 1')
          expect(user.link).to eq(nil)
        end
      end
    end

    context 'limit' do
      it do
        expect(query.limit(nil).all.count).to eq(2)
        expect(query.limit(0).all.count).to eq(0)
        expect(query.limit(1).all.count).to eq(1)
        expect(query.limit(2).all.count).to eq(2)
      end
    end
  end

  context '#first' do
    subject { query.first }

    it do
      expect(subject).to be_instance_of(TestCase::User)
    end

    it do
      expect(subject.name).to eq('User 1')
    end
  end

  context 'relation' do
    it do
      expect(RemoteResource::Html::Model.path('a')).to be_instance_of(RemoteResource::Model::Relation)
    end

    it do
      expect(RemoteResource::Html::Model.path('a').attributes).to eq(path: 'a')
      expect(RemoteResource::Html::Model.path('a').path('b').attributes).to eq(path: 'b')
      expect(RemoteResource::Html::Model.path('a').path).to eq('a')
    end
  end

  context 'mappings' do
    it do
      expect(TestCase::User.mappings).to have_key(:default)
      expect(TestCase::User.mappings).to have_key(:only_name)
    end
  end

end
