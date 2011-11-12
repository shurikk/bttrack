
require 'fileutils'

module Bttrack

  class InfoHash

    attr_reader :id
    
    def initialize(params)
      @params = params
      validate
    end
    
    def validate
      raise 'info_hash is missing' if @params[:info_hash].nil?

      @id = Array(@params[:info_hash].unpack('H*'))[0].to_s

      raise 'invalid info_hash' unless
        @id =~ /[\w\d]{40}/
    end
    
    def peers(args)
      {
        'interval' => CONF[:announce_interval],
        'min interval' => CONF[:min_interval],
        'peers' => args[:compact] ?
          peers_compact(args[:numwant]) : peers_dictionary(args)
      }
    end
    
    # args: peer (peer_id, ip, port), downloaded, uploaded, left
    def event(args)
      peer = args[:peer]

      case args[:event]
      when 'stopped'
        delete_peer(peer.id)
      else
        File.open("#{path}/#{peer.id}", 'wb') {|f|
          f.write(Marshal.dump({
            'downloaded' => args[:downloaded],
            'uploaded'   => args[:uploaded],
            'left'       => args[:left],
            'ip'         => peer.ip,
            'port'       => peer.port
          }))
        }
      end

      cleanup
    end
    
    # info_hash home dir
    def path
      path = "#{CONF[:db_dir]}/#{id[0..1]}/#{id[2..3]}/#{id}"
      `mkdir -p #{path}` unless File.directory?(path)
      path
    end
    
    def peers_list_all
      Dir.chdir(path)
      Dir.glob('[a-z0-9]*').shuffle
    end
    
    # num - number of entries to return
    def peers_list(num)
      peers_list_all[0..num].map do |peer_id|
        hash = Marshal.load(File.open(peer_id, 'rb').read)
        hash['peer_id'] = peer_id
        hash
      end
    end
    
    # num - number of entries requested
    def peers_compact(num)
      peers_list(num).map do |hash|
        [hash['ip'].to_i, hash['port'].to_i].pack('Nn')
      end.join
    end
    
    # :numwant - number of peers requested
    # :no_peer_id - don't include peer_id in response
    def peers_dictionary(args)
      peers_list(args[:numwant]).map do |h|
        d = {'ip' => h['ip'].to_i, 'port' => h['port'].to_i}
        d['peer_id'] = [h['peer_id']].pack('H*') unless args[:no_peer_id]
        d
      end
    end
    
    def delete_peer(id)
      File.delete(id)
    end

    def cleanup

      Dir.chdir(path)

      # cleanup every 60 seconds?
      return if File.exists?('.cleanup') &&
        Time.now - File.stat('.cleanup').mtime < CONF[:cleanup_interval]

      FileUtils.touch('.cleanup')
      
      Dir.glob('[a-z0-9]*').map do |peer_id|
        delete_peer(peer_id) unless 
          Time.now - File.stat(peer_id).mtime < CONF[:announce_interval]*2
      end

    end

    def scrape
      
      # compile new .scrape file
      if !File.exists?('.scrape') ||
        Time.now - File.stat('.scrape').mtime > CONF[:scrape_interval]
        
        # calculate
        scrape = peers_list_all.inject({
          'info_hash' => [id].pack('H*'),
          'downloaded' => 0,
          'complete' => 0,
          'incomplete' => 0
        }) do |scrape,peer_id|
          hash = Marshal.load(File.open(peer_id, 'rb').read)
          
          if hash['left'] == 0
            scrape['complete'] += 1
          else
            scrape['incomplete'] += 1
          end

          scrape
        end

        File.open("#{path}/.scrape", 'wb') {|f|  f.write(Marshal.dump(scrape)) }

      else
        scrape = Marshal.load(File.open("#{path}/.scrape", 'rb').read)
      end

      scrape
    end
    
    # scrape for all torrents
    def self.scrape
      Dir.glob("#{CONF[:db_dir]}/**/.scrape").map do |f|
        Marshal.load(File.open(f).read)
      end
    end
  end

end
