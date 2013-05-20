require 'sinatra'

$BTTRACK_ROOT = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH << "#{$BTTRACK_ROOT}/lib"

require 'bttrack/config'
require 'bttrack/request'
require 'config/config' if File.exists?("#{$BTTRACK_ROOT}/config/config.rb")

helpers do
  def req
    Bttrack::Request.new(params.merge(
      :remote_ip => request.ip
    ))
  end
end

error do
  request.env['sinatra.error'].message
end

get '/' do
  @version = `cat #{$BTTRACK_ROOT}/VERSION`
  @torrents = Dir.glob("#{CONF[:db_dir]}/*/*/*")
  erb :index
end

get '/info/:id' do
  @info_hash = Bttrack::InfoHash.new id: params[:id]
  @peers = @info_hash.peers_list(100).map do |p|
    p['ip'] = [24, 16, 8, 0].collect {|b| (p['ip'] >> b) & 255}.join('.')
    p
  end
  erb :info
end

get '/announce' do
  info_hash = req.info_hash

  peers = info_hash.peers(
    :compact => req.compact?,
    :no_peer_id => req.no_peer_id?,
    :numwant => req.numwant
  )

  info_hash.event(
    :event => req.event,
    :downloaded => req.downloaded,
    :uploaded => req.uploaded,
    :left => req.left,
    :peer => req.peer
  )

  peers.bencode
end

get '/scrape' do
  (request[:info_hash].nil? ? 
    Bttrack::InfoHash.scrape :
    req.info_hash.scrape).bencode
end

__END__
@@ layout
<html>
  <body>
   <%= yield %>
  </body>
</html>

@@ index
bttrack version <%= @version %><br/>
tracking <%= @torrents.size %> torrent(s)
<ul>
<% @torrents.each do |torrent| %>
  <% torrent = torrent.split('/').last %>
  <li><a href="/info/<%= torrent %>"><%= torrent %></a></li>
<% end %>
</ul>

@@ info
torrent: <%= @info_hash.id %><br/>
peers:
<ul>
<% @peers.each do |peer| %>
  <li><%= peer %></a></li>
<% end %>
</ul>
