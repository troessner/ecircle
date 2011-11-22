dir = File.dirname(__FILE__)
require File.join(dir, '..', 'lib', 'ecircle')

require 'random_data'

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
