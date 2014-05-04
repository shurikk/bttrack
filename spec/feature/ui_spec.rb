# encoding: utf-8
require 'spec_helper'

describe "GET /" do
  it "shows blank list if there is no data" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include "bttrack"
    expect(last_response.body).to include "Torrents (0)"
  end

  it "shows torrent details table" do
    FileStore.new("info_hash_abcdefghij").set_peer "abcd", left: 9876
    FileStore.new("info_hash_1234567890").set_peer "abcd", {}
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include "Torrents (2)"
    expect(last_response.body).to include "4353637383930" # torrent 1
    expect(last_response.body).to include "465666768696a" # torrent 2
    expect(last_response.body).to match /seed[">\n ]+1/m
    expect(last_response.body).to match /leech[">\n ]+0/m
    expect(last_response.body).to match /seed[">\n ]+0/m
    expect(last_response.body).to match /leech[">\n ]+1/m
  end
end

describe "GET /:info_hash" do
  let(:info_hash) { "info_hash_abcdefghij" }
  let(:hex_info_hash) { info_hash.unpack('H*')[0] }
  let(:store) { FileStore.new(info_hash) }
  subject { get "/#{hex_info_hash}" }

  it "fails if info_hash is invalid" do
    get '/12312abcd'
    expect(last_response).to be_not_found
  end

  it "shows page even if there is no data" do
    subject
    expect(last_response).to be_ok
    expect(last_response.body).to include hex_info_hash
    expect(last_response.body).not_to include info_hash
    expect(last_response.body).not_to include "<sub>MB"   # no torrent size
  end

  it "show torrent size guessed from peers" do
    store.set_peer "abcd", downloaded: 9876
    store.set_peer "efgh", left: 1487600
    subject
    expect(last_response).to be_ok
    expect(last_response.body).to include "1.49 <sub>MB"
  end

  it "shows peer details table" do
    store.set_peer "abcd", downloaded: 9876, ip: '8.8.8.8', port: '42', uploaded: 2700000
    store.set_peer "efgh", {}
    subject
    expect(last_response).to be_ok
    expect(last_response.body).to include "Peers (2)"
    expect(last_response.body).to include "61626364"      # code 1
    expect(last_response.body).to include "8.8.8.8:42"    # ip
    expect(last_response.body).to include "100 <sub>%"    # status
    expect(last_response.body).to include "2.7 <sub>MB"   # uploaded
    expect(last_response.body).to include "65666768"      # code 2
  end
end