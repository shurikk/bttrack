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
  erb :index
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
bttrack version <%= @version %>
