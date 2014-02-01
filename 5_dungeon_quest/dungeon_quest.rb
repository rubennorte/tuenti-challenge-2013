#!/usr/bin/env ruby

def process_input
  test_cases = []
  test_case_count = gets.to_i
  test_case_count.times do
    grid = gets.chomp.split(',').map(&:to_i)
    grid = Array.new(grid[0]) { Array.new(grid[1], 0) }
    pos = gets.chomp.split(',').map(&:to_i)
    seconds = gets.to_i
    gem_count = gets.to_i
    gets.chomp.split('#').each do |gem_spec|
      gem = gem_spec.split(',').map(&:to_i)
      grid[gem[0]][gem[1]] = gem[2]
    end
    test_cases << [grid, pos, seconds]
  end
  test_cases
end

def new_possible_positions(grid, pos, prev_pos)
  [
    [pos[0]-1, pos[1]],
    [pos[0]+1, pos[1]],
    [pos[0], pos[1]-1],
    [pos[0], pos[1]+1],
  ].reject { |pos| pos == prev_pos || pos[0] == grid.size || pos[0] == -1 || pos[1] == grid[0].size || pos[1] == -1 }
end

def maximum_value(grid, pos, seconds, value=0, prev_pos=nil)

  return value if seconds == 0

  max = value

  new_possible_positions(grid, pos, prev_pos).each do |new_pos|

    # Move to new possition and take gem value from grid
    gem_val = grid[new_pos[0]][new_pos[1]]
    value += gem_val
    grid[new_pos[0]][new_pos[1]] = 0

    new_value = maximum_value(grid, new_pos, seconds-1, value, pos)

    if new_value > max
      max = new_value
    end

    # Return gem value to grid and substract from total
    value -= gem_val
    grid[new_pos[0]][new_pos[1]] = gem_val
  end

  max
end

test_cases = process_input
test_cases.each { |test_case| puts maximum_value(*test_case) }