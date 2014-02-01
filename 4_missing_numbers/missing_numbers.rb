#!/usr/bin/env ruby

def process_input
  positions = []
  test_cases = gets.to_i
  test_cases.times do
    positions << gets.to_i
  end
  positions
end

file = File.open(File.join(File.dirname(__FILE__), 'missing_integers'), 'rb')

positions = process_input
positions.each do |position|

  file.rewind
  file.seek((position-1)*4)
  missing_number = file.read(4).unpack('L')
  puts missing_number

end
