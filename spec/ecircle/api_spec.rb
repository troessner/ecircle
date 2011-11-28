require 'spec_helper'

describe Ecircle::Api do
  describe 'obtain_auth_token' do
    it 'should obtain an auth token for the first time' do
      savon.expects(:logon).returns(:success)
      subject.obtain_auth_token
    end

    it 'should touch auth_token_last_used_at' do
      savon.expects(:logon).returns(:success)
      before_call = Time.now
      subject.obtain_auth_token

      auth_token_last_used_at = subject.instance_variable_get('@auth_token_last_used_at')
      before_call.should <= auth_token_last_used_at
      auth_token_last_used_at.should <= Time.now
    end

    it 'should return the token' do
      savon.expects(:logon).returns(:success)
      subject.obtain_auth_token.should eq('foo')
    end

    describe 'subsequent calls' do
      before do
        savon.expects(:logon).returns(:success)
        @auth_token = subject.obtain_auth_token
      end

      it 'should re-use auth token' do
        savon.expects(:logon).never
        subject.obtain_auth_token.should eq(@auth_token)
      end

      it 'should touch auth_token_last_used_at' do
        before_call = Time.now
        subject.obtain_auth_token

        auth_token_last_used_at = subject.instance_variable_get('@auth_token_last_used_at')
        before_call.should <= auth_token_last_used_at
        auth_token_last_used_at.should <= Time.now
      end

      it 'should request another auth token if current one expired' do
        subject.instance_variable_set('@auth_token_last_used_at', Time.now - Ecircle::Api::AUTH_TOKEN_TIMEOUT - 1)
        savon.expects(:logon).returns(:success)
        subject.obtain_auth_token
      end
    end
  end

  describe 'create_member' do
    it 'should obtain an auth token' do
      savon.stubs(:createMember).returns(:success)
      subject.expects(:obtain_auth_token)

      subject.create_member(nil, nil)
    end

    it 'should pass proper parameters' do
      savon.expects(:createMember).
        with(:session => 'foo', :userId => 1, :groupId => 2,
             :invite => 'false', :sendMessage => 'false').
        returns(:success)
      subject.stubs(:obtain_auth_token).returns('foo')

      wrapped_response = subject.create_member(1, 2)
    end

    it 'should parse proper response segment' do
      savon.stubs(:createMember).returns(:success)
      subject.stubs(:obtain_auth_token)

      wrapped_response = subject.create_member(nil, nil)

      wrapped_response.ecircle_id.should eq('123456')
    end
  end
end
