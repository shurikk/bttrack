require 'environment'
require 'bttrack/config'
require 'bttrack/peer'

class PeerTest < Test::Unit::TestCase
  def setup
    @params = {
      :peer_id => "torr/0.10|\245\250\225\345\371\332\213?+\024",
      :remote_ip => '1.1.1.1'
    }
  end

  def test_peer_id
    p = Bttrack::Peer.new(@params)

    assert_equal "746f72722f302e31307ca5a895e5f9da8b3f2b14", p.id
    assert_equal 16843009, p.ip
  end

  def test_ip_override
    CONF[:allow_ip_override] = true
    
    @params[:ip] = '2.2.2.2' 

    p = Bttrack::Peer.new(@params)
    
    assert_equal 33686018, p.ip
  end
end
