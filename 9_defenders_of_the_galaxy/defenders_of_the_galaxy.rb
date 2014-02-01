#!/usr/bin/env ruby
# encoding: utf-8

# Given:
#   vo => initial speed of the Zorglings (1m/s)
#   s  => number of trained soldiers
#   c  => number of crematoriums
#   w  => width of the canyon (meters)
#   h  => height of the canyon (meters)
#   t  => resistance time (seconds)
#
# The progress speed of the group of Zorglings is:
#   v = w - s
# Notice that when v <= 0 the resistance time is infinite.
#
# The retention time (time the Zorglings need to reach the wall) is:
#   r = w*(h-1)/v + 1
#
# The resistance time would be:
#   t = r * (1+c)
#
# In order to maximize the resistance time, we need to adjust the variables
# in our control, in this case s and c.

def process_input
  test_case_count = gets.to_i
  test_cases = test_case_count.times.map do
    gets.split(' ').map(&:to_i)
  end
end

def resistance_time(width, height, soldiers, crematoriums)
  speed = width-soldiers
  return Float::INFINITY if speed <= 0

  retention_time = width*(height-1)/speed + 1
  time = retention_time * (1+crematoriums)

  time.to_f
end

def maximum_resistance_time(width, height, soldier_price, crematorium_price, gold)

  max_soldiers = gold/soldier_price
  max_time = 0.0

  soldiers = max_soldiers

  while soldiers >= 0 do

    remaining_gold = gold - soldiers*soldier_price
    crematoriums = remaining_gold/crematorium_price

    time = resistance_time(width, height, soldiers, crematoriums)
    if time > max_time
      max_time = time
    end

    return max_time if max_time.infinite?

    # Substract soldiers and add crematoriums
    while soldiers >= 0 && remaining_gold/crematorium_price == crematoriums
      remaining_gold = remaining_gold + soldier_price
      soldiers -= 1
    end

  end

  max_time

end

test_cases = process_input
test_cases.each do |test_case|
  max_time = maximum_resistance_time(*test_case)
  max_time = -1 if max_time.infinite?
  puts max_time.round
end
