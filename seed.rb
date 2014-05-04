#!/usr/bin/env ruby
# Generates random data for local testing

require 'securerandom'
require './bttrack'

FileStore.purge!

20.times do
  info_hash = InfoHash.new SecureRandom.random_bytes(20)
  size = rand(100_000..1_000_000_000)
  (rand(1..5)**2).times do
    down = [0, size, rand(0..size)].sample
    up = [0, rand(0..64)**8].sample
    left = [0, size-down].sample
    info_hash.event! 'peer_id' => SecureRandom.random_bytes(20),
      'ip' => ([rand(1..99)]*4).join('.'), 'downloaded' => down, 'uploaded' => up, 'left' => left, 'port' => rand(1024..32767)
  end
end
