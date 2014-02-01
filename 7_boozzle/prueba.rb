#!/usr/bin/env ruby
# encoding: utf-8

# def value_of(combinations, word_values)
#   combinations.each_pair.reduce(0) do |memo, combinations|
#     length = combination[0]
#     quantity = combination[1]
#     next(0) if quantity == 0

#     word_values[length][0..count-1].reduce(0) do |memo, value|
#       memo + value
#     end
#   end
# end

def best_score(remaining_time, word_lengths, words={}, current={}, current_score=0)

  if word_lengths.size == 0 || remaining_time < word_lengths.last
    puts "current: #{current}"
    return current_score
  end

  max_score = current_score

  duration = word_lengths.first

  limit = [remaining_time/duration, words[duration].size].min

  limit.downto(0) do |quantity|

    remaining = remaining_time - quantity * duration

    score = best_score(remaining, word_lengths[1..-1], words, current.merge(duration => quantity))

    if score < max_score
      max_score = score
    end

  end

  max_score

end

best_score(80, [10, 2, 1], {10 => [{}, {}], 2 => [{}, {}, {}], 1 => [{}]})