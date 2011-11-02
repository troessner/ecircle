[![Build Status](https://secure.travis-ci.org/troessner/ecircle.png)](http://travis-ci.org/troessner/ecircle)

Synopsis
-------------

This gem aims to be a full-fledged solution for the ecircle API, the [synchronous one](http://webservices.ecircle-ag.com/soap/javadoc/com/ecircleag/webservices/EcMApi.html) and the [asynchronous one](http://developer.ecircle-ag.com/apiwiki/wiki/AsynchronousAPI).

This is WIP and far from complete.

Features
-------------

So far just a couple of methods:

* create_member
* create_or_update_user_by_email
* delete_member
* logon
* send_parametrized_single_message_to_user

To do
-------------

* Rethink current structure
* Implement missing API methods
* Specs
* RDoc

Configuration
-------------

```Ruby
Ecircle.configure do |config|
  config.user     = 'your@user.com'
  config.realm    = 'http://your.realm.com'
  config.password = 'your_password'
end
```

Usage
-------------

```Ruby
Ecircle.create_or_update_user_by_email 'user@email.com'
```