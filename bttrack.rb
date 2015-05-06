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

VERSION = File.read('VERSION')

helpers do
  def failure code=400, reason
    halt code, {'failure reason' => reason}.bencode
  end

  def size_format size
    if size > (10**12)
      "%.3g <sub>TB</sub>" % (size.to_f / 10**12)
    elsif size > (10**9)
      "%.3g <sub>GB</sub>" % (size.to_f / 10**9)
    else
      "%.3g <sub>MB</sub>" % (size.to_f / 10**6)
    end
  end
end

get '/' do
  @torrents = InfoHash.all
  erb :index
end

get %r{/([0-9a-f]{40})} do
  @store = FileStore.new params[:captures].pack('H*')
  @tr = request.url.gsub /#{@store.info_hash.unpack('H*')[0]}$/, 'announce'
  erb :show
end

get '/announce' do
  content_type 'text/plain'
  failure 'info_hash is missing' if params['info_hash'].nil?
  failure 'peer_id is missing' if params['peer_id'].nil?
  failure 'port is missing' if params['port'].nil?
  failure 'invalid info_hash' if params['info_hash'].bytesize != 20
  failure 'invalid peer_id' if params['peer_id'].bytesize != 20
  failure 'invalid numwant' if params['numwant'].to_i > CONF[:max_peers]

  info_hash = InfoHash.new params['info_hash']

  info_hash.event!({"ip" => request.ip}.merge(params))
  info_hash.announce(
    params[:compact].to_i == 1 || CONF[:compact_only],
    params[:no_peer_id].to_i == 1,
    (params[:numwant] || CONF[:default_peers]).to_i
  ).bencode
end

get '/scrape' do
  content_type 'text/plain'
  if params['info_hash']
    failure 'invalid info_hash' if params['info_hash'].bytesize != 20
    InfoHash.new(params['info_hash']).scrape.bencode
  else
    InfoHash.scrape.bencode
  end
end
