#!/usr/bin/env ruby

require './config'

input = File.open(File.join(File.dirname(__FILE__), 'integers'), 'rb')
output = File.open(File.join(File.dirname(__FILE__), 'partially-sorted-integers'), 'wb')

chunk = ' ' * MyConfig::SECTION_SIZE

while input.read(MyConfig::SECTION_SIZE, chunk) do
  values = chunk.unpack('L*')
  values.sort!
  output.write(values.pack('L*'))
end

input.close
output.close