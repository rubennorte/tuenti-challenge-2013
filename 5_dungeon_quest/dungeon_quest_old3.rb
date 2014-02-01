#!/usr/bin/env ruby

def process_input
  test_cases = []
  test_case_count = gets.to_i
  test_case_count.times do
    grid = gets.chomp.split(',').map(&:to_i)
    pos = gets.chomp.split(',').map(&:to_i)
    seconds = gets.to_i
    gem_count = gets.to_i
    gems = gets.chomp.split('#').map do |gem_spec|
      gem_spec.split(',').map(&:to_i)
    end
    test_cases << [pos, seconds, gems]
  end
  test_cases
end

def cost_to_visit(pos, prev_pos, gem)

  cost = (pos[0] - gem[0]).abs + (pos[1] - gem[1]).abs

  return cost if prev_pos.nil?

  if pos[0] == prev_pos[0] && prev_pos[0] == gem[0]
    # Same row
    if pos[1] > prev_pos[1] && gem[1] <= prev_pos[1]
      cost += 2
    elsif pos[1] < prev_pos[1] && gem[1] >= prev_pos[1]
      cost += 2
    end
  elsif pos[1] == prev_pos[1] && prev_pos[1] == gem[1]
    # Same column
    if pos[0] > prev_pos[0] && gem[0] <= prev_pos[0]
      cost += 2
    elsif pos[0] < prev_pos[0] && gem[0] >= prev_pos[0]
      cost += 2
    end
  end

  cost
end

# Returns all the gems reachable from the current position
# ordered by its value
def available_gems(pos, seconds, gems, prev_pos=nil)
  available = gems.map { |gem| [gem, cost_to_visit(pos, prev_pos, gem)] }
  available.select! { |gem_with_cost| gem_with_cost[1] <= seconds }
  available.sort_by! { |gem_with_cost| gem_with_cost[1] }
  available
end

def maximum_value(pos, seconds, available, value=0, prev_pos=nil)
  result = value

  available.each do |gem_with_cost|

    gem = gem_with_cost[0]

    new_pos = gem[0..1]
    new_seconds = seconds - gem_with_cost[1]
    new_gems = []
    available.each do |gem_with_cost|
      new_gems << gem_with_cost[0] if gem_with_cost[0] != gem
    end
    new_value = value + gem[2]

    next_available = available_gems(new_pos, new_seconds, new_gems, pos)
    total_value = next_available.reduce(0) do |memo, gem|
      memo + gem[0][2]
    end

    # Bound
    next if new_value + total_value <= result
 
    new_result = maximum_value(new_pos, new_seconds, next_available, new_value, pos)

    if new_result > result
      result = new_result
    end

  end

  result
end

test_cases = process_input
test_cases.each do |test_case|
  pos, seconds, gems = test_case
  gems = available_gems(pos, seconds, gems)
  puts maximum_value(pos, seconds, gems)
end