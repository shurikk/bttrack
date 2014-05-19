# encoding: utf-8
require 'spec_helper'

describe "GET /scrape" do
  let(:info_hash) { "info_hash_abcdefghij" }
  let(:response) { BEncode.load(last_response.body) }
  let(:store) { FileStore.new(info_hash) }

  it "fails if info_hash is invalid" do
    get '/scrape', info_hash: 'abcd'
    expect(last_response).to_not be_ok
    expect(response).to include('failure reason' => 'invalid info_hash')
  end

  it "counts properly UTF-8 chars" do
    get '/scrape', info_hash: "Amq@\n*c\u001A\xB4\x8D\xBAo\xA6S\xABǌ\u0001\x8D\xBA"
    expect(last_response).to be_ok
    expect(response).not_to include('failure reason')
  end

  it "returns stats for one hash" do
    store.set_peer "abcd", ip: '42.5.4.3', port: 432, left: 9876
    store.set_peer "efgh", ip: '22.5.4.8', port: 431, uploaded: 9876
    get '/scrape', info_hash: info_hash
    expect(last_response).to be_ok
    expect(response).to include('files' => {
      info_hash => {'complete' => 1, 'downloaded' => 0, 'incomplete' => 1}
    })
  end

  it "returns stats for all torrents" do
    FileStore.new('1234').set_peer "abcd", ip: '42.5.4.3', port: 432, left: 9876
    FileStore.new('5678').set_peer "efgh", ip: '22.5.4.8', port: 431, uploaded: 9876
    get '/scrape'
    expect(last_response).to be_ok
    expect(response).to include('files' => {
      '1234' => {'complete' => 0, 'downloaded' => 0, 'incomplete' => 1},
      '5678' => {'complete' => 1, 'downloaded' => 0, 'incomplete' => 0}
    })
  end
end