require 'bttrack/peer'
require 'bttrack/info_hash'

module Bttrack
  
  class Request 
    def initialize(params)
      @params = params
    end
    
    def info_hash
      @info_hash ||= InfoHash.new(@params)
    end

    def peer
      @peer ||= Peer.new(@params)
    end

    def compact?
      @params[:compact].to_i == 1 || CONF[:compact]
    end

    def no_peer_id?
      @params[:no_peer_id].to_i != 1
    end

    def numwant
      n = @params[:numwant].nil? ? CONF[:default_peers] : @params[:numwant].to_i
      n = (n == 0 || n > CONF[:max_peers]) ? CONF[:max_peers] : n
    end

    def downloaded
      @params[:downloaded].to_i
    end

    def uploaded
      @params[:uploaded].to_i
    end

    def left
      @params[:left].to_i
    end
    
    def event
      @params[:event].to_s
    end
  end

end
