Webhook-Templates
=================

Templates to render webhook data into p.im compatible format.

Template engines
----------------

Currently we're only using the [LinkedIn fork][dustjs-linkedin] of
[Dust.js][].

How to add a new service
------------------------

Step 1: Clone this repository

Step 2: Create a sample for the webhook data, e.g. by using
[requestb.in][], and save just the JSON payload into 
samples/*servicename*.json  
**NOTE:** If the service uses `application/x-www-form-urlencoded` then
simply translate the payload into it's JSON equivalent and then follow
step 2.

Step 3: Write your expected output into expect/*sample_filename*.txt

Step 4: Write a template in [Dust.js][] format, with a
**WebhookTemplate** header (see below), and save it into
templates/*servicename*.dust

Step 5: Build the template via `make`

Step 6: Test it by running `make test`  
**NOTE:** if it fails, then go back to step 4

Once you have it working, you can send this repository a pull request.

A note on dust.js
-----------------

We ignore whitespace to make formatting/reading the templates easier. If
you need a space where it wouldn't normally render one then use `{~s}`
and for newlines use `{~n}`.

WebhookTemplate header
----------------------

A WebhookTemplate header is a [Dust.js][] comment containing a JSON
payload describing the template. JSON must be valid as determined by
Node.JS' `JSON.parse`.

Here is an example:

    {!WebhookTemplate{
      "name"      : "GitHub"
    , "author"    : "Benjie Gillam (http://www.benjiegillam.com/)"
    , "format"    : "JSON"
    , "jsonfield" : "payload"
    , "ips"       : ["207.97.227.253", "50.57.128.197", "108.171.174.178"]
    , "url"       : "http://help.github.com/post-receive-hooks/"
    }!}

### Fields
Other fields than those specified below may be added, so long as they're
sensible. If you add a field please also add a description of it to the
README (this file).

#### name (required)
The display name for the template, concise

#### author (required)
`Barney Rubble <b@rubble.com> (http://barnyrubble.tumblr.com/)`

Name is required, and either one or both of email address or web address
must be specified (to aid disambiguation).

#### format (required)
The format of the data the webhook provider emits - e.g. `JSON`, `XML` or
`form`.  
**NOTE:** we do not support XML at this time, but if you want it
supported then feel free to submit a pull request.

#### jsonfield (if necessary)
If the data will be submitted as `application/x-www-form-urlencoded` but
with a JSON payload then this is the name of the field that contains the JSON.

#### ips (optional)
This is the IP addresses from which the service may post. If known,
please specify for security reasons.

#### url (optional)
A link to the details about the service's webhook implementation.

[dustjs-linkedin]: https://github.com/linkedin/dustjs
[Dust.js]: http://akdubya.github.com/dustjs/
[requestb.in]: http://requestb.in/
