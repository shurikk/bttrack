Ruby/Sinatra BitTorrent Tracker
===============================

Simple [BitTorrent](http://bittorrent.org/) tracker using [Sinatra](http://www.sinatrarb.com/) that doesn't require database backend

Implemented: [BEP 3](http://bittorrent.org/beps/bep_0003.html), [BEP 23](http://bittorrent.org/beps/bep_0023.html)


Thoughts
--------

In general idea is to run multiple torrent trackers (for redundancy) + fancy
command line torrent clients that know how to share .torrent files with each
other as a bittorrent based storage that is somewhat similar to [amazon S3](https://s3.amazonaws.com/)
and others.


Installation
------------
 
running on localhost, port 8888, using rack

    $ git clone git://github.com/shurikk/bttrack.git
    $ cd bttrack ; bundle install
    $ bundle exec rackup -p 8888

or create a .torrent file and use http://btrack.heroku.com/announce as announce URL


License
-------

Released under the MIT license.


Contributors
------------

- Alexander Kabanov
