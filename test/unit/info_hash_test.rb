
require 'environment'
require 'bttrack/config'
require 'bttrack/info_hash'

class InfoHashTest < Test::Unit::TestCase

  def setup
    @req = Bttrack::Request.new(
      :info_hash => "\333\035\266\331Q\016x}\315r\261\253\006\234R\005\002\246\2362",
      :peer_id => "torr/0.10|\245\250\225\345\371\332\213?+\024",
      :downloaded => 0,
      :uploaded => 0,
      :left => 1024,
      :remote_ip => '1.1.1.1'
    )

    @info_hash = @req.info_hash
    @peer = @req.peer
  end

  def teardown
    if File.exists?("#{@info_hash.path}/#{@peer.id}")
      File.delete("#{@info_hash.path}/#{@peer.id}")
    end
  end

  def test_event
    @info_hash.event(
      :event => 'started',
      :downloaded => @req.downloaded,
      :uploaded => @req.uploaded,
      :left => @req.left,
      :peer => @req.peer
    )

    assert File.exists?("#{@info_hash.path}/#{@peer.id}")
    assert @info_hash.peers_dictionary(:numwant => 10, :no_peer_id => false)[0]['peer_id']
    assert @info_hash.peers_compact(10)

    @info_hash.event(
      :event => 'stopped',
      :peer => @peer
    )

    assert !File.exists?("#{@info_hash.path}/#{@peer.id}")
  end

  def test_delete_missing_file
    assert !File.exists?("#{@info_hash.path}/#{@peer.id}")
    assert_nothing_raised Errno::ENOENT do
      @info_hash.event :event => 'stopped',:peer => @peer
    end
  end

  def test_scrape
    @info_hash.event(
      :event => 'started',
      :downloaded => @req.downloaded,
      :uploaded => @req.uploaded,
      :left => @req.left,
      :peer => @peer
    )

    assert @info_hash.scrape['info_hash']
  end

  def test_scrape_all
    @info_hash.event(
      :event => 'started',
      :downloaded => @req.downloaded,
      :uploaded => @req.uploaded,
      :left => @req.left,
      :peer => @peer
    )

    assert Bttrack::InfoHash.scrape[0]['info_hash']
  end
end
