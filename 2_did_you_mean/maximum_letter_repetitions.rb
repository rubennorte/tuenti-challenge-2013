#!/usr/bin/env ruby

file = ARGV.first

alphabet = "abcdefghijklmnopqrstuvwxyz"
max = alphabet.size
more_than_max = 0

File.open(file).each do |line|

  letter_repetition = Array.new(alphabet.size, 0)
  line = line[0..-2]
  line.each_char do |letter|
    index = alphabet.index(letter)
    if index.nil?
      puts "Letter #{letter} not found"
    else
      letter_repetition[index] += 1
    end
  end
  if letter_repetition.any?{|v| v > max}
    more_than_max += 1
    puts "The word #{line} contains more than #{max} times the same letter"
  end
end

if more_than_max > 0
  puts "There are words which contain more than #{max} times the same letter"
else
  puts "There are not words which contain more than #{max} times the same letter"
end
