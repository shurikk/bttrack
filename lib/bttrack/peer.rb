
require 'ipaddr'

module Bttrack

  class Peer
    
    attr_reader :id

    def initialize(params)
      @params = params
      validate
    end

    def validate
      raise 'peer_id is missing' if @params[:peer_id].nil?

      @id = Array(@params[:peer_id].unpack('H*'))[0].to_s

      raise 'invalid peer_id' unless
        @id =~ /[\w\d]{40}/
    end

    def ip
      ip = @params[:remote_ip]
      
      new_ip = @params[:ip].to_s
      
      if CONF[:allow_ip_override] && @params[:ip] && new_ip =~ /^\d+\.\d+\.\d+\.\d+$/
        # ip validation is not strict and IPv4 only, basic sanity check
        ip = new_ip
      end

      IPAddr.new(ip).to_i
    end

    def port
      @params[:port] ? @params[:port].to_i : 6881
    end

  end

end
