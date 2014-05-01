# encoding: utf-8
require 'spec_helper'

describe "GET /announce" do
  let(:info_hash) { "info_hash_abcdefghij" }
  let(:peer_id) { "peer_id_5q27wml14wai" }
  let(:args) { {info_hash: info_hash, peer_id: peer_id, port: 6881} }
  let(:response) { BEncode.load(last_response.body) }
  let(:store) { FileStore.new(info_hash) }

  describe "error handling" do
    it "fails if info_hash is missing" do
      get '/announce', peer_id: peer_id, port: 6881
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'info_hash is missing')
    end

    it "fails if peer_id is missing" do
      get '/announce', info_hash: info_hash, port: 6881
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'peer_id is missing')
    end

    it "fails if port is missing" do
      get '/announce', info_hash: info_hash, peer_id: peer_id
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'port is missing')
    end

    it "fails if info_hash is invalid" do
      get '/announce', info_hash: 'abcd', peer_id: peer_id, port: 6881
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'invalid info_hash')
    end

    it "fails if peer_id is invalid" do
      get '/announce', info_hash: info_hash, peer_id: 'abcd', port: 6881
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'invalid peer_id')
    end

    it "fails if numwant is too high" do
      get '/announce', args.merge(numwant: 1000)
      expect(last_response).to_not be_ok
      expect(response).to include('failure reason' => 'invalid numwant')
    end

    it "counts properly UTF-8 chars" do
      get '/announce', args.merge(info_hash: "Amq@\n*c\u001A\xB4\x8D\xBAo\xA6S\xABǌ\u0001\x8D\xBA")
      expect(last_response).to be_ok
      expect(response).not_to include('failure reason')
    end
  end

  describe "returns peers" do
    before :each do
      store.set_peer "abcd", ip: '42.5.4.3', port: 432, left: 9876
      store.set_peer "efgh", ip: '22.5.4.8', port: 431, uploaded: 9876
    end

    after { CONF[:compact_only] = false }

    it "in dictionary form" do
      get '/announce', args
      expect(last_response).to be_ok
      # TODO: content type text
      expect(response).to include('interval' => 600)
      expect(response).to include('min interval' => 60)
      expect(response['peers']).to have(3).items
      expect(response).to include('peers' => [
        {'ip' => '42.5.4.3', 'peer id' => 'abcd', 'port' => 432},
        {'ip' => '22.5.4.8', 'peer id' => 'efgh', 'port' => 431},
        {'ip' => '127.0.0.1', 'peer id' => peer_id, 'port' => 6881}
      ])
    end

    it "in compact form if asked" do
      get '/announce', args.merge(compact: 1)
      expect(response).to include('peers' => [
        IPAddr.new('42.5.4.3').to_i, 432,
        IPAddr.new('22.5.4.8').to_i, 431,
        IPAddr.new('127.0.0.1').to_i, 6881
      ].pack('NnNnNn'))
    end

    it "in compact form if forced" do
      CONF[:compact_only] = true
      get '/announce', args
        expect(response).to include('peers' => [
        IPAddr.new('42.5.4.3').to_i, 432,
        IPAddr.new('22.5.4.8').to_i, 431,
        IPAddr.new('127.0.0.1').to_i, 6881
      ].pack('NnNnNn'))
    end

    it "excluding peer id if asked" do
      get '/announce', args.merge(no_peer_id: 1)
      expect(response['peers']).to have(3).items
      expect(response).to include('peers' => [
        {'ip' => '42.5.4.3', 'port' => 432},
        {'ip' => '22.5.4.8', 'port' => 431},
        {'ip' => '127.0.0.1', 'port' => 6881}
      ])
    end

    it "limited to numwant if provided" do
      get '/announce', args.merge(numwant: 2)
      expect(response['peers']).to have(2).items
    end
  end

  describe "stopped event" do
    context "with matching entry" do
      before :each do
        store.set_peer peer_id, ip: '42.5.4.3', port: 432
      end

      it "removes peer from list" do
        expect {
          get '/announce', args.merge(event: 'stopped')
        }.to change { store.get_peers.size }.by(-1)
      end

      it "deletes file if empty" do
        expect {
          get '/announce', args.merge(event: 'stopped')
        }.to change { store.file_path.exist? }.to false
      end
    end

    context "with no matching entry" do
      it "does nothing" do
        expect {
          get '/announce', args.merge(event: 'stopped')
        }.not_to change { store.get_peers.size }.from(0)
      end
    end
  end

  describe "with started or completed event" do
    it "created peer entry" do
      expect {
        get '/announce', args.merge(event: 'started', left: 512)
      }.to change { store.get_peers.size }.by(1)
      peer = store.get_peer peer_id
      expect(peer).to include ip: '127.0.0.1', port: 6881
      expect(peer).to include downloaded: 0, uploaded: 0, left: 512
    end

    it "updates peer entry" do
      store.set_peer peer_id, ip: '42.5.4.3', port: 432
      expect {
        get '/announce', args.merge(event: 'completed', downloaded: 512)
      }.to change { store.get_peers.size }.by(0)
      peer = store.get_peer peer_id
      expect(peer).to include ip: '127.0.0.1', port: 6881
      expect(peer).to include downloaded: 512, uploaded: 0, left: 0
    end
  end
end