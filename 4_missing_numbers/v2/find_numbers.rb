#!/usr/bin/env ruby

require 'date'

MEGABYTES = 1024 * 1024
MAP_SIZE = 256 * MEGABYTES
BUFFER_SIZE = 128 * MEGABYTES
MASKS = [1, 2, 4, 8, 16, 32, 64, 128]

# Returns the location of the integer in the map (byte, bit)
def get_location(integer)
  bit = integer % 8
  byte = integer / 8
  [byte, bit]
end

def get_presence_map_from_file(input)
  map = ''.concat(0) * MAP_SIZE
  chunk = ''.concat(0) * BUFFER_SIZE

  max_number = -1

  input.seek(0)
  while input.read(BUFFER_SIZE, chunk) do
    for int_num in 0..(chunk.size-1)/4
      int_pos = int_num * 4
      integer = chunk[int_pos..int_pos+3].unpack('L')[0]
      max_number = integer if integer > max_number
      byte, bit = get_location(integer)
      map.setbyte(byte, map.getbyte(byte) | MASKS[bit])
    end
  end

  [map, max_number]
end

def get_missing_from_byte(byte, byte_pos, max_number)
  missing = []

  # Optimization if there's no missing number in the byte
  return [missing, false] if byte == 255

  base = byte_pos * 8
  MASKS.each_with_index do |mask, bit|
    return [missing, true] if base + bit > max_number
    missing << base + bit if byte & mask == 0
  end

  [missing, false]
end

def get_missing(input)
  missing = []
  presence, max_number = get_presence_map_from_file(input)
  for byte_pos in 0..presence.size-1
    byte = presence.getbyte(byte_pos)
    new_missing, finished = get_missing_from_byte(byte, byte_pos, max_number)
    missing += new_missing
    return missing if finished
  end
  missing
end

def init(path)
  input = File.open(path, 'rb')
  missing = get_missing(input)
  input.close
  puts missing.join("\n")
end

init(ARGV[0])