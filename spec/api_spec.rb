require 'spec_helper'

describe Ecircle::Api do
  before :all do
    Ecircle.configure do |config|
      config.user        = ''
      config.sync_realm  = ''
      config.password    = ''
    end
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
end
