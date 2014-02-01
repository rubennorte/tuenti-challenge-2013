#!/usr/bin/env ruby
# encoding: utf-8

require './config'

file = ARGV.first
section = ARGV[1] || 0
section = section.to_i

input = File.open(file, 'rb')

input.seek(section * MyConfig::SECTION_SIZE)

puts input.read(MyConfig::SECTION_SIZE).unpack('L*')

input.close
