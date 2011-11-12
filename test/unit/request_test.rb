
require 'environment'
require 'bttrack/config'
require 'bttrack/request'

class RequestTest < Test::Unit::TestCase
  def test_info_hash
    r = Bttrack::Request.new(
      :info_hash => "\333\035\266\331Q\016x}\315r\261\253\006\234R\005\002\246\2362",
      :peer_id => "torr/0.10|\245\250\225\345\371\332\213?+\024"
    )
    
    assert_equal "db1db6d9510e787dcd72b1ab069c520502a69e32", r.info_hash.id
    assert_equal "746f72722f302e31307ca5a895e5f9da8b3f2b14", r.peer.id
  end

end
