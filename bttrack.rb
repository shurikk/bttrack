require 'sinatra'
require 'bencode'
require './lib/info_hash'

CONF = {
  compact_only: false,      # Only return peers in compact format
  announce_interval: 600,   # Desired interval between announce
  min_interval: 60,         # Min interval between announce
  default_peers: 50,        # Default number of peers returned per announce
  max_peers: 200,           # Max number of peers returned per announce
  db_dir: "./tmp/torrents"  # Where to store database files
}

set :db_dir, 'toto'

helpers do
  def numwant
    num = params[:numwant].to_i
    num = CONF[:max_peers] if num > CONF[:max_peers]
    num = CONF[:default_peers] if num <= 0
    num
  end

  def failure code=400, reason
    halt code, {'failure reason' => reason}.bencode
  end
end

get '/' do
  @torrents = InfoHash.all
  erb :index
end

get '/info/:id' do
  @store = FileStore.new [params[:id]].pack('H*')
  erb :show
end

get '/announce' do
  content_type 'text/plain'
  failure 'info_hash is missing' if params['info_hash'].nil?
  failure 'peer_id is missing' if params['peer_id'].nil?
  failure 'invalid info_hash' if params['info_hash'].size != 20
  failure 'invalid peer_id' if params['peer_id'].size != 20

  info_hash = InfoHash.new params['info_hash']
  failure 403, 'access denied, key mismatch' if info_hash.key_mismatch?(params)

  info_hash.event!({"ip" => request.ip}.merge(params))
  info_hash.announce(numwant: numwant,
    compact: (params[:compact].to_i == 1 || CONF[:compact_only]),
    no_peer_id: (params[:no_peer_id].to_i == 1)
  ).bencode
end

get '/scrape' do
  content_type 'text/plain'
  if params['info_hash']
    failure 'invalid info_hash' if params['info_hash'].size != 20
    InfoHash.new(params['info_hash']).scrape.bencode
  else
    InfoHash.scrape.bencode
  end
end
