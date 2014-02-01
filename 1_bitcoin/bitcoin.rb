#!/usr/bin/env ruby

test_cases = gets.to_i

results = []

test_cases.times do

  euros = gets.to_i
  bitcoins = 0
  rates = gets.split(/\s+/).map(&:to_i)

  unique_rates = [rates.first]
  rates.each_index do |i|
    next if i == 0
    unique_rates << rates[i] if rates[i] != rates[i-1]
  end

  rates = unique_rates
  # to determine if the first and the last element are a maximimum or minimum
  rates = [rates[1]] + rates + [rates[-2]]

  inflections = []

  rates.each_index do |i|
    next if i == 0
    next if i == rates.size-1

    if rates[i-1] < rates[i] && rates[i] > rates[i+1]
      # is a maximum (sell if we have bitcoins)
      inflections << rates[i] if inflections.size > 0
    elsif rates[i-1] > rates[i] && rates[i] < rates[i+1]
      # is a minimum (buy)
      inflections << rates[i]
    end
  end

  if inflections.size % 2 != 0
    inflections = inflections[0..-2]
  end

  inflections.each_with_index do |rate, i|
    if i % 2 == 0
      # buy
      bitcoins = euros / rate
      euros = 0
    else
      # sell
      euros = bitcoins * rate
      bitcoins = 0
    end
  end

  results << euros

end

puts results