#!/usr/bin/env ruby

MEGABYTES = 1024 * 1024
BUFFER_SIZE = 128 * MEGABYTES

def create_test_file(filename, max_number, missing_count, missing_filename = nil)
  if max_number < missing_count
    raise 'The missing count should be lower than the maximum number'
  end

  File.open(filename, 'wb') do |file|
    numbers = (0..max_number).to_a.shuffle!
    present = numbers.slice!(missing_count..numbers.size-1)
    missing = numbers.sort!
    file.write(present.pack('L*'))
    if missing_filename
      File.open(missing_filename, 'w') do |missing_file|
        missing_file.write(missing.join("\n"))
      end
    end
  end

end

create_test_file(ARGV[0], ARGV[1].to_i, ARGV[2].to_i, ARGV[3])