[![Build Status](https://secure.travis-ci.org/troessner/ecircle.png)](http://travis-ci.org/troessner/ecircle)

Synopsis
-------------

This gem aims to be a full-fledged solution for the ecircle API, the [synchronous one](http://webservices.ecircle-ag.com/soap/javadoc/com/ecircleag/webservices/EcMApi.html) and the [asynchronous one](http://developer.ecircle-ag.com/apiwiki/wiki/AsynchronousAPI).

The API coverage is far from complete.

However, the existing API coverage can be considered stable and is used in production.

Features
-------------

So far just a couple of methods:

* create_member
* create_or_update_user_by_email
* delete_member
* logon (only for debugging purposes)
* send_parametrized_single_message_to_user

See the rdoc for details on arguments and return values: [TODO Add link]

To do
-------------

* Implement missing API methods
* Specs
* Remove JobPackage from gem since this is highly specific

Configuration
-------------

```Ruby
Ecircle.configure do |config|
  config.user       = 'your@user.com'
  config.sync_realm = 'http://your.realm.com'
  config.password   = 'your_password'
end
```

The reason for the unusual configuration setting "sync_realm" is that there is also an asynchronous ecircle API with a different realm.

Logon
-------------

The ecircle gem does the session handling for you, there is no need to logon explicitly.
Session tokens will be re-used to keep the number of session related traffic to a minimum.


Examples
-------------

```Ruby
# Given you have called Ecircle.configure appropriatly...

# 1.) Create a user
uid = Ecircle.create_or_update_user_by_email 'your@email.com'
puts "Ecircle user ID: #{uid}"

# 2.) Add this user as a member to a group - e.g. for newsletters
mid = Ecircle.create_member uid, 'your_group_id'
puts "Ecircle member Id: #{mid}"

# 3.) Delete member from group - e.g. when he unsubscribes
Ecircle.delete_member mid

# 4.) Send the user a transactional email:
Ecircle.send_parametrized_single_message_to_user uid,
                                                your_template_id_at_ecircle,
                                                [ :name, :message ],
                                                [ 'Tom', 'welcome!' ]

```