Travis Build Status
-------------

[![Build Status](https://secure.travis-ci.org/troessner/ecircle.png)](http://travis-ci.org/troessner/ecircle)

Synopsis
-------------

This gem aims to be a full-fledged solution for the ecircle API, the [synchronous one](http://webservices.ecircle-ag.com/soap/javadoc/com/ecircleag/webservices/EcMApi.html) and the [asynchronous one](http://developer.ecircle-ag.com/apiwiki/wiki/AsynchronousAPI).

The API coverage is far from complete, however as far as I can see the most useful / frequent methods are covered.

The existing API methods can be considered stable and are used in production.

Installation
-------------

Either as a gem:

    gem install ecircle

or via Bundler by adding it to your Gemfile.

Configuration
-------------

    Ecircle.configure do |config|
      config.user       = 'your@user.com'
      config.sync_realm = 'http://your.realm.com'
      config.password   = 'your_password'
    end

The reason for the unusual configuration setting "sync_realm" is that there is also an asynchronous ecircle API with a different realm.

Response handling
-------------

The ecircle gem will always return a wrapped response for all API methods, except for the logon method (see examples below or the API doc).

The wrapped response object is just a neat abstraction to hide Ecircle's horrible, horrible error handling from you and provides several methods for doing so.

The most usefull (and self-explanatory) would be:

* success?
* error_message
* fault_code
* ecircle_id IF the API returns an ID an success, e.g. for create_member and create_or_update_user_by_email
* convenience methods which depend on your (failed request), e.g.:
  * member_does_not_exist? (delete_member requests)
  * message_id_does_not_exist? (send_parametrized_message_to_user requests)
  * no_such_group? (create_member requests)
  * no_such_user? (create_member_requests)

For details see [here](http://rubydoc.info/github/troessner/ecircle/master/Ecircle/WrappedResponse)

Features
-------------

###Synchronous API

The following methods are implemented:

* createMember
* createOrUpdateGroup
* createOrUpdateUserByEmail
* deleteGroup
* deleteMember
* logon (only for debugging purposes)
* logout
* sendParametrizedSingleMessageToUser

See the [online API documentation](http://rubydoc.info/github/troessner/ecircle/master/frames) for details on arguments and return values

###Asnchronous API

Since the asynchronous API is neither documented by ecircle nor intuitive at all, you're on your own. Jump to the examples section and good luck.


Using ecircle
-------------

### Synchronous API

    # Given you have called Ecircle.configure appropriatly...

    # 1.) Create a user
    r = Ecircle.create_or_update_user_by_email 'your@email.com'
    uid = r.ecircle_id
    puts "Ecircle user ID: #{uid}"

    # 2.) Create a group
    r = Ecircle.create_or_update_group :name => 'ecircletestgroup', :description => 'ecircletestgroup', :email => 'email@your.ecircle.domain.de'
    gid = r.ecircle_id
    puts "Ecircle group ID: #{gid}"

    # 3.) Add this user as a member to a group - e.g. for newsletters
    r = Ecircle.create_member uid, gid
    mid = r.ecircle_id
    puts "Ecircle member Id: #{mid}"

    # 4.) Delete member from group - e.g. when he unsubscribes
    Ecircle.delete_member mid

    # 5.) Send the user a transactional email:
    Ecircle.send_parametrized_single_message_to_user uid,
                                                    your_template_id_at_ecircle,
                                                    [ :name, :message ],
                                                    [ 'Tom', 'welcome!' ]

    # 6.) Delete the group
    Ecircle.delete_group your_group_id

    # 7.) Log out
    Ecircle.logout


### Asynchronous API

Note the async_realm in the configure block, this another realm as for the sync API.

    Ecircle.configure do |config|
      config.user        = 'your@user.com'
      config.async_realm = 'http://your.async.realm.com' # IMPORTANT - different realm.
      config.password    = 'your_password'
    end

    @options = {
      :endpoint                     => 'http://your.domain/eC-MessageService',
      :request_id                   => '1234',
      :group_id                     => '5678',
      :send_out_date                => 70.minutes.from_now, # Must be at least one hour in the future!
      :send_date_for_report         => 140.minutes.from_now,  # Must be at least one hour in the future *after* dispatching!
      :report_email                 => 'your@report.de',
      :report_email_name            => 'Your name',
      :subject                      => 'Newsletter',
      :text                         => 'Newsletter text content',
      :html                         => 'Newsletter html content'
    }

    Ecircle::JobPackage.send_async_message_to_group @options

To do
-------------

* Implement missing API methods:
 * deleteUser
 * deleteUserByEmail
 * lookupGroups
* Write specs

Logon
-------------

The ecircle gem does the session handling for you, there is no need to logon explicitly.
Session tokens will be re-used to keep the number of session related traffic to a minimum.

Documentation
-------------

* [Online API Documentation](http://rubydoc.info/github/troessner/ecircle/master/frames)
