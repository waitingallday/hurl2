Hurl
====

Hurl was created for the Rails Rumble 2009 in 48 hours.
Now Hurl is an open source project for your enjoyment.

<http://hurl.it/>


Installation
------------

Hurl requires Ruby 1.8.6+

First download hurl and cd into the directory:

    git clone git://github.com/twilio/hurl
    cd hurl

Or download [the zip](http://github.com/twilio/hurl/zipball/master).

Next make sure you have [RubyGems](https://rubygems.org/pages/download) installed.

Then install [Bundler](http://gembundler.com/):

    gem install bundler

Now install Hurl's dependencies:

    bundle install


Run Locally
-----------

    bundle install
    bundle exec shotgun config.ru

### Setting up Postgres

Make sure you have the user `postgres` created

In `psql` run:

    # CREATE DATABASE hurls;
    # \connect hurls;
    # create table views (id character(40), content bytea);
    # create table hurls (id character(40), content bytea);
    # create table users (id character(40), content bytea);

Make sure to have the proper permissions:
    # Assign owner to postgres
    # ALTER TABLE views OWNER TO postgres;
    # ALTER TABLE hurls OWNER TO postgres;
    # ALTER TABLE users OWNER TO postgres;

Now visit <http://localhost:9393>

Run in Heroku
-------------

    heroku create
    git push heroku master
    heroku open

This will open a copy of Hurl running on your own private Heroku instance.


Issues
------

Find a bug? Want a feature? Submit an [issue
here](http://github.com/twilio/hurl/issues). Patches welcome!


Screenshot
----------

[![Hurl](http://img.skitch.com/20091020-xtiqtj4eajuxs43iu5h3be7upj.png)](http://hurl.it)


Original Authors
----------------

* [Leah Culver][2]
* [Chris Wanstrath][3]


[1]: http://r09.railsrumble.com/
