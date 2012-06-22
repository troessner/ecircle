require 'ecircle'
require 'savon_spec'

def random_group_email suffix
  "apitest#{Random.number(100000)}@#{suffix}"
end

def create_random_group suffix
  group_attributes = { :name        => 'API TEST',
                       :description => 'API TEST',
                       :email       => random_group_email(suffix) }
  @ecircle_group_id ||= Ecircle.create_or_update_group(group_attributes).ecircle_id
end

def test_user_id
  @ecircle_user_id ||= Ecircle.create_or_update_user_by_email(:email => 'apitest@apitest.com').ecircle_id
end

Savon::Spec::Fixture.path = File.expand_path('../fixtures', __FILE__)

RSpec::configure do |c|
  c.include Savon::Spec::Macros
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
