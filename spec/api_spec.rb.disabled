require 'spec_helper'

describe Ecircle::Api do
  #IMPORTANT:
  #In order to run the functional specs you need to fill in the configuration values at the top of spec/api_spec.rb.disabled
  #with your ecircle account data and then rename spec/api_spec.rb.disabled to spec/api_spec.rb.
  #
  #Currently you need to clean up created groups and members manually afterwards (yes, I know that sucks) since
  #ecircle doesn't offer a test api so all tests are going against the live API.
  #Without a test API I figured it's too dangerous to execute destructive actions like delete_group so the only actions
  #which are actually tested are non-destructive like create_or_update_user.... and so on, but never methods like delete_group.
  #Finding data that has been created by the tests is pretty easy, right now there is only one user with email
  #'apitest@apitest.com' and one or more groups whose names are 'API TEST' so you can easily find test remnants via the web interface.
  # TODO Add more edge cases where things can go wrong, e.g. create_or_update_user with an invalid email etc.
  before :each do
    Ecircle.configure do |config|
      config.user        = ''
      config.sync_realm  = ''
      config.password    = ''
    end
    @email_suffix = '' # This MUST be your ecircle domain e.g. 'newsletter.your.company.com'
    # You need to create this message before in the webinterface, there's no way of doing this automatically.
    @test_message_id = '1200095137'
  end

  describe 'ensuring_logon' do
    context 'wrong credentials' do
      it 'should immediately raise an exception' do
        Ecircle.configuration.password = 'invalid'
        expect do
          dummy_proc = Proc.new {}
          Ecircle.api.ensuring_logon &dummy_proc
        end.to raise_error(Ecircle::InvalidLoginCredentials)
      end

      context 'stale session token' do
        it 'should retry exactly once to obtain a new token' do
          response = Ecircle::WrappedResponse.new :success => false
          response.stub(:not_authenticated?).and_return(true)
          dummy_proc = Proc.new { response }
          expect do
            Ecircle.api.ensuring_logon &dummy_proc
          end.to raise_error
        end
      end
    end
  end

  describe 'create_or_update_group' do
    it 'should return the ecircle id' do
      group_attributes = { :name        => 'API TEST',
                           :description => 'API TEST',
                           :email       => random_group_email(@email_suffix) }
      res = Ecircle.create_or_update_group group_attributes
      res.success?.should be_true
      res.ecircle_id.to_s.should =~ /\d+/
    end
  end

  describe 'create_member' do
    it 'should create a member' do
      group_id = create_random_group @email_suffix
      user_id  = test_user_id
      res = Ecircle.create_member user_id, group_id
      res.success?.should be_true
      res.ecircle_id.to_s.should =~ /\d+/
    end
  end

  describe 'create_or_update_user_by_email' do
    it 'should return the ecircle id' do
      res = Ecircle.create_or_update_user_by_email :email => 'apitest@apitest.com'
      res.success?.should be_true
      res.ecircle_id.to_s.should =~ /\d+/
    end
  end

  describe 'delete_group' do
    # TODO Implement but ONLY once ecircle provides a test API.
  end

  describe 'delete_member' do
    # TODO Implement but ONLY once ecircle provides a test API.
  end

  describe 'send_parametrized_single_message_to_user' do
    it 'should return success' do
      res = Ecircle.send_parametrized_single_message_to_user test_user_id, @test_message_id
      res.success?.should be_true
    end

    it 'should return a corresponding error message if the template does not exist' do
      res = Ecircle.send_parametrized_single_message_to_user test_user_id, Random.number(10000)
      res.success?.should be_false
      res.message_id_does_not_exist?.should be_true
    end
  end
end
