#!/usr/bin/env ruby
# encoding: utf-8

# Given:
#   vo => initial speed of the Zorglings (1m/s)
#   s  => number of trained soldiers
#   c  => number of crematoriums
#   w  => width of the canyon (meters)
#   h  => height of the canyon (meters)
#   t  => resist time (seconds)
#
# The progress speed of the group of Zorglings is:
#   v = vo - s/w
#
# The resistance time is:
#   t = h/v + h*c
# Notice that when s >= w, v <= 0 and then the resistance time is infinite.
#
# In order to maximize the resistance time, we need to adjust the variables
# in our control, in this case s and c.


def process_input
  test_case_count = gets.to_i
  test_cases = test_case_count.times.map do
    gets.split(' ').map(&:to_i) + [1] # Zordlings speed (1m/s)
  end
end

def resistance_time(width, height, soldiers, crematoriums, speed)
  speed = speed - soldiers/width
  return Float::INFINITY if speed <= 0

  time = height.to_f/speed + height*crematoriums
  time
end

def maximum_resistance_time(width, height, soldier_price, crematorium_price, gold, speed)

  max_soldiers = gold/soldier_price
  max_crematoriums = gold/crematorium_price

  max_time = 0
  last_soldiers = 0
  last_crematoriums = 0

  max_soldiers.downto(0) do |soldiers|

    remaining_gold = gold - soldiers*soldier_price
    crematoriums = remaining_gold/crematorium_price

    time = resistance_time(width, height, soldiers, crematoriums, speed)
    if time > max_time
      max_time = time
    end

    return max_time if max_time.infinite?

  end

  max_time

end

test_cases = process_input
test_cases.each do |test_case|
  max_time = maximum_resistance_time(*test_case)
  if max_time.infinite?
    puts -1
  else
    puts max_time.round
  end
end
