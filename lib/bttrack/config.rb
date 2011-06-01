
# config defaults
# create $BTTRACK_ROOT/config/config.rb to override defaults

CONF = {
  :compact => true,
  :allow_ip_override => false,
  :announce_interval => 1800,
  :cleanup_interval => 60,
  :min_interval => 900,
  :default_peers => 50,
  :scrape_interval => 10,
  :max_peers => 200,
  :db_dir => "#{$BTTRACK_ROOT}/tmp/torrents"
} 
