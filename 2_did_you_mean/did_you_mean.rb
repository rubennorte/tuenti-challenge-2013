#!/usr/bin/env ruby

def get_next
  begin
    line = gets
  end while /\s*#/ =~ line
  line.gsub(/\n$/, '')
end

def parse_input
  dictionary = get_next
  number_of_sugestions = get_next.to_i

  words = []
  number_of_sugestions.times do
    words << get_next
  end

  [dictionary, words]
end

ALPHABET = ('a'..'z').to_a

def key_for(word)
  key = Array.new(ALPHABET.size, ALPHABET.first)
  word.each_char do |char|
    char_pos = char.ord - ALPHABET.first.ord
    key[char_pos] = key[char_pos].next
  end
  key.join('')
end

def process_dictionary(dictionary)
  dict_hash = {}
  
  dictionary = File.join(Dir.getwd, dictionary)

  File.open(dictionary).each do |line|
    line.gsub!(/\n$/, '')
    key = key_for(line)
    words = dict_hash[key]
    if words
      words << line
    else
      dict_hash[key] = [line]
    end
  end

  dict_hash
end

dictionary, words = parse_input
dict_hash = process_dictionary(dictionary)

words.each do |word|
  suggestions = dict_hash[key_for(word)] || []
  suggestions = suggestions.reject{|w| w == word}
  puts "#{word} -> #{suggestions.join(' ')}"
end
