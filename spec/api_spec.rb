require 'spec_helper'

describe Ecircle::Api do
  before :all do
    Ecircle.configure do |config|
      config.user        = ''
      config.sync_realm  = ''
      config.password    = ''
    end
    @group_email_address = 'test@your.sub.domain.com'
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
      group_attributes = { :name        => 'your name',
                           :description => 'desc',
                           :email       => @group_email_address }
      res = Ecircle.create_or_update_group group_attributes
      res.success?.should be_true
      res.ecircle_id.to_s.should =~ /\d+/
    end
  end

  describe 'create_member' do

  end

  describe 'create_or_update_user_by_email' do

  end

  describe 'delete_group' do

  end

  describe 'delete_member' do

  end

  describe 'send_parametrized_single_message_to_user' do

  end
end
