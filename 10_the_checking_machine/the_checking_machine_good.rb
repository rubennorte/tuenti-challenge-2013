#!/usr/bin/env ruby
# encoding: utf-8

require "digest/md5"

def get_tokens(input)
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

def get_text(tokens)

  return '' if tokens.size == 0

  if tokens.first[:type] == :string
    return tokens.first[:value] + get_text(tokens[1..-1])
  end

  if tokens.first[:type] == :multiplier
    multiplier = tokens.first[:value]
    initial = ''
    current = 1

    if current < tokens.size && tokens[current][:type] == :open

      opened = 1
      current += 1
      substr_start = current
      while opened != 0 && current < tokens.size do
        if tokens[current][:type] == :open
          opened += 1
        elsif tokens[current][:type] == :closed
          opened -= 1
        end
        current += 1
      end

      return initial + (get_text(tokens[substr_start..current-1]) * multiplier) + get_text(tokens[current..-1])
    end
  end

  ''

end

def get_md5(input)
  text = get_text(get_tokens(input))
  Digest::MD5.hexdigest(text)
end

while !(input = gets.chomp).empty? do
  puts get_md5(input)
end