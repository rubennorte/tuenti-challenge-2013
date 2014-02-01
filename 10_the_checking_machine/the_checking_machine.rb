#!/usr/bin/env ruby
# encoding: utf-8

require "digest/md5"

# Returns the list of tokens in the input
def scan(input)
  tokens = input.scan(/[a-z]+|\d+|\[|\]/)
  tokens.map do |token|
    type = nil
    value = token
    case token
      when /\d+/ then
        type = :multiplier
        value = value.to_i
      when /[a-z]+/ then
        type = :string
      when '[' then
        type = :open
      when ']' then
        type = :close
    end

    {
      value: value,
      type: type
    }
  end
end

# Returns the syntax tree
def parse(tokens)
  result = []
  return result if tokens.size == 0

  current = 0
  while current < tokens.size && tokens[current][:type] != :close

    if tokens[current][:type] == :string
      result << tokens[current]
      current += 1
    elsif tokens[current][:type] == :multiplier
      token = tokens[current]
      current += 2
      fragment, read = parse(tokens[current..-1])
      current += read

      token[:child] = fragment
      result << token
    end

  end

  current += 1 if current < tokens.size 

  [result, current]
end

def generate_output(tree, file)

  tree.each do |token|

    if token[:type] == :string
      file.write(token[:value])
    else
      offset = file.size
      generate_output(token[:child], file)
      length = file.size - offset
      (token[:value]-1).times do
        File.copy_stream(file, file, length, offset)
      end
      file.seek(0, IO::SEEK_END)
    end

  end

end

def get_md5(input)
  filename = File.join(File.dirname(__FILE__), 'temp.txt')
  file = File.new(filename, 'w+')

  tokens = scan(input)
  tree, pos = parse(tokens)
  generate_output(tree, file)

  file.close

  puts `md5sum #{filename}`.split(' ')[0]
end

while !(input = gets.chomp).empty? do
  get_md5(input)
end