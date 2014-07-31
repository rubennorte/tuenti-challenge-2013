#!/usr/bin/env ruby

require './config'
require './integer_buffer'

CHUNK = " " * (MyConfig::INPUT_BUFFER_SIZE*4)

def load_buffer(input, offsets, buffer, pos)
  offset = offsets[pos]
  return if offset >= MyConfig::SECTION_SIZE/MyConfig::INPUT_BUFFER_SIZE
  
  input.rewind
  input.seek(pos*MyConfig::SECTION_SIZE + offset*MyConfig::INPUT_BUFFER_SIZE)
  input.read(MyConfig::INPUT_BUFFER_SIZE, CHUNK)
  buffer.values = CHUNK.unpack('L*')

  offsets[pos] += 1
end

input = File.open(File.join(File.dirname(__FILE__), 'partially-sorted-integers'), 'rb')

chunk_count = (input.size.to_f / MyConfig::SECTION_SIZE).ceil

input_buffers = Array.new(chunk_count) { IntegerBuffer.new(0) }
input_offsets = Array.new(chunk_count, 0)

input_buffers.each_with_index do |buffer, i|
  load_buffer(input, input_offsets, buffer, i)
end

last_value = nil
missing = []
remaining_buffers = input_buffers.dup

while remaining_buffers.size > 0 do

  min_buf = remaining_buffers.min_by { |buf| buf.last }

  value = min_buf.last
  if last_value and value > last_value+1
    puts "#{last_value+1}..#{value-1}"
    new_missing = (last_value+1..value-1).to_a
    puts "new_missing: #{new_missing}"
    missing = missing + new_missing
    break if missing.size >= 100
  end
  if last_value and value < last_value
    puts "Esto no deberia pasar!!!"
    exit
  end
  min_buf.read
  last_value = value

  # skip consecutive numbers of this buffer (optimization)
  last_value = min_buf.read while !min_buf.eof? && last_value == min_buf.last-1

  # load more data if needed
  if min_buf.eof?
    pos = input_buffers.index(min_buf)
    puts "Loading more data in buffer #{pos}"
    load_buffer(input, input_offsets, min_buf, pos)
    if min_buf.eof?
      remaining_buffers.delete(min_buf)
    end
  end

end

File.open('./missing_integers', 'wb') { |f| f.write(missing.pack('L*')) }
input.close
