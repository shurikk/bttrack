require 'ipaddr'
require './lib/file_store'

class InfoHash
  def initialize id
    @id = id
  end

  # returns announce details with peer list
  def announce compact, no_peer_id, numwant
    peer_list = store.get_peers(numwant).map do |peer_id, peer|
      if compact
        [IPAddr.new(peer[:ip]).to_i, peer[:port].to_i].pack('Nn')
      else
        {'ip' => peer[:ip], 'port' => peer[:port].to_i}.tap do |data|
          data['peer id'] = peer_id unless no_peer_id
        end
      end
    end
    { 'interval' => CONF[:announce_interval],
      'min interval' => CONF[:min_interval],
      'peers' => compact ? peer_list.join : peer_list }
  end

  # updates peer's details
  def event! params
    if params["event"] == 'stopped'
      store.delete_peer params['peer_id']
    else
      store.set_peer params['peer_id'], ip: params["ip"],
        downloaded: params["downloaded"].to_i, uploaded: params["uploaded"].to_i,
        left: params["left"].to_i, port: params["port"].to_i
    end
  end

  # https://wiki.theory.org/BitTorrentSpecification#Tracker_.27scrape.27_Convention
  def scrape
    defaults = {downloaded: 0, complete: 0, incomplete: 0}
    {:files => { @id => defaults.merge(store.get_stats) }}
  end

  def self.all
    Enumerator.new do |enum|
      Pathname.glob("#{CONF[:db_dir]}/*.pstore").each do |path|
        enum.yield [path.basename('.pstore').to_s].pack('H*')
      end
    end
  end

  # scrape for all torrents
  def self.scrape
    defaults = {downloaded: 0, complete: 0, incomplete: 0}
    {:files => InfoHash.all.each_with_object({}) do |info_hash, stats|
      stats[info_hash] = defaults.merge(FileStore.new(info_hash).get_stats)
    end}
  end

  private

  def store
    @store ||= FileStore.new(@id)
  end

end