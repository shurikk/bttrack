Ruby/Sinatra BitTorrent Tracker
===============================

Simple [BitTorrent](http://bittorrent.org/) tracker using [Sinatra](http://www.sinatrarb.com/) that doesn't require database backend

Implements [BEP 3](http://bittorrent.org/beps/bep_0003.html) and [BEP 23](http://bittorrent.org/beps/bep_0023.html)

Installation
------------

Running on localhost:

    $ git clone git://github.com/shurikk/bttrack.git
    $ cd bttrack
    $ bundle install
    $ bundle exec rackup

You can also use my public heroku instance: create a .torrent file and use http://bttrack.heroku.com/announce as announce URL.

Configuration
-------------

Configuration options are available at the top of `bttrack.rb`

Contributors
------------

* [Alexander Kabanov](http://github.com/shurikk)
* [Adrien Jarthon](http://github.com/jarthod)
