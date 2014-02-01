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

def direction(pos, new_pos)
  [new_pos[0] <=> pos[0], new_pos[1] <=> pos[1]]
end

def opposite_direction(pos, prev_pos, new_pos)
  return false if pos.nil? || prev_pos.nil? || new_pos.nil?

  new_direction = direction(pos, new_pos)
  new_direction_axis = new_direction.index(0)

  # Diagonal (never comes back)
  return false if new_direction_axis.nil?

  prev_direction = direction(prev_pos, pos)
  prev_direction_axis = prev_direction.index(0)

  # Different axes
  return false if prev_direction_axis != new_direction_axis

  return prev_direction[(prev_direction_axis+1)%2] != new_direction[(new_direction_axis+1)%2]
end

def same_row_or_column(pos, new_pos)
  pos[0] == new_pos[0] || pos[1] == new_pos[1]
end

# Cost to visit a gem from a position given the previous position
# (if it has to turn around, 2 movements need to be added)
def cost_to_visit(pos, prev_pos, gem)
  cost = (pos[0] - gem[0]).abs + (pos[1] - gem[1]).abs
  cost += 2 if opposite_direction(pos, prev_pos, gem)
  cost
end

# Determines if a cell if in the path from one cell to another
def between_cells?(a_cell, one_cell, prev_pos, another_cell)
  return false if opposite_direction(one_cell, prev_pos, a_cell)

  row_range = one_cell[0] <= another_cell[0] ?
    one_cell[0]..another_cell[0] : another_cell[0]..one_cell[0]
  column_range = one_cell[1] <= another_cell[1] ?
    one_cell[1]..another_cell[1] : another_cell[1]..one_cell[1]

  row_range.include?(a_cell[0]) && column_range.include?(a_cell[1])
end

def side_cells(prev_pos, pos)
  turned = direction(prev_pos, pos).reverse!
  [
    pos.each_with_index.map{|val, i| val + turned[i] },
    pos.each_with_index.map{|val, i| val - turned[i] }
  ]
end

# Determines if exists any gem in the path from pos to gem_with_cost
def gems_in_path?(pos, prev_pos, gem_with_cost, gems_with_cost)
  test = (gem_with_cost[0][0..1] == [3,3])
  gems_in_p = gems_with_cost.any? do |other_gem|
    return false if other_gem == gem_with_cost

    if opposite_direction(pos, prev_pos, other_gem[0])
      sides = side_cells(prev_pos, pos)
      return true if between_cells?(other_gem[0], sides[0], prev_pos, gem_with_cost[0])
      return true if between_cells?(other_gem[0], sides[1], prev_pos, gem_with_cost[0])
    else
      return between_cells?(other_gem[0], pos, prev_pos, gem_with_cost[0])
    end
  end
end

# Returns all the gems reachable from the current position
# ordered by its value
def available_gems(pos, seconds, gems, prev_pos)
  # Compute cost to visit all gems
  gems_with_cost = gems.map { |gem| [gem, cost_to_visit(pos, prev_pos, gem)] }
  # Filter unreachable gems
  gems_with_cost.select! { |gem_with_cost| gem_with_cost[1] <= seconds }
  # Remove gems when there are other gems in the path to them
  gems_with_cost.select! { |gem_with_cost| !gems_in_path?(pos, prev_pos, gem_with_cost, gems_with_cost) }
  # Sort by distance
  gems_with_cost.sort_by! { |gem_with_cost| gem_with_cost[0][2] }

  gems_with_cost
end

def value_of(path)
  path.reduce(0) do |memo, gem|
    memo + gem[2]
  end
end

def substract_direction(pos, dir)
  [pos[0] - dir[0], pos[1] - dir[1]]
end

def possible_arrival_cells(pos, prev_pos, gem)
  arrival = []

  dir = direction(pos, gem)

  if !dir.index(0).nil?
    if opposite_direction(pos, prev_pos, gem)
      # if it has to turn around, get the possible arrival cells from both sides
      sides = side_cells(prev_pos, pos)
      arrival += possible_arrival_cells(sides[0], pos, gem)
      arrival += possible_arrival_cells(sides[1], pos, gem)
    else
      arrival << substract_direction(gem, dir)
    end
  else
    approach_1 = substract_direction(gem, [dir[0], 0])
    approach_2 = substract_direction(gem, [0, dir[1]])

    arrival << approach_1 if !opposite_direction(pos, prev_pos, approach_1)
    arrival << approach_2 if !opposite_direction(pos, prev_pos, approach_2)
  end

  arrival
end

def maximum_value(pos, seconds, gems, path=[], prev_pos=nil)
  result = path

  gems_with_cost = available_gems(pos, seconds, gems, prev_pos)
  gems_with_cost.each do |gem_with_cost|

    gem = gem_with_cost[0]

    new_pos = gem[0..1]
    new_seconds = seconds - gem_with_cost[1]
    new_gems = gems - [gem]
    new_path = path + [gem]

    possible_arrival_cells(pos, prev_pos, gem).each do |pos|
      new_result = maximum_value(new_pos, new_seconds, new_gems, new_path, pos)

      if value_of(new_result) > value_of(result)
        result = new_result
      end
    end

  end

  result
end

test_cases = process_input
test_cases.each { |test_case| puts value_of(maximum_value(*test_case)) }
