#!/usr/bin/env ruby
# encoding: utf-8

def char_to_symbol(char)
  case char
  when '·' then :ice
  when '#' then :rock
  when 'X' then :visited
  when 'O' then :exit
  else
    puts "Wrong symbol"
    exit
  end
end

def process_input
  test_cases = []
  test_case_count = gets.to_i
  test_case_count.times do
    cols, rows, speed, stop_time = gets.chomp.split(' ').map(&:to_i)
    grid = Array.new(rows)
    me = nil
    grid.each_index do |row|
      grid[row] = gets.chomp.split('').each_with_index.map do |char, col|
        symbol = char_to_symbol(char)
        me = [row, col] if symbol == :visited
        symbol
      end
    end
    test_cases << [grid, me, speed, stop_time]
  end
  test_cases
end

DIRECTIONS = [
  [0,-1],  # NORTH
  [0, 1],  # SOUTH
  [1, 0],  # EAST
  [-1, 0], # WEST
]

def get_symbol(grid, pos)
  grid[pos[0]][pos[1]]
end

def add_positions(pos, other_pos)
  [pos[0] + other_pos[0], pos[1] + other_pos[1]]
end

def substract_positions(pos, other_pos)
  [pos[0] - other_pos[0], pos[1] - other_pos[1]]
end

def next_movements(grid, me, speed)

  movements = []

  DIRECTIONS.each do |dir|
    # Initial position is "me"
    pos = me

    # Find a rock o the exit
    pos = add_positions(pos, dir) while ![:rock, :exit].include?(get_symbol(grid, pos))

    symbol = get_symbol(grid, pos)

    # Step back
    if symbol == :rock
      pos = substract_positions(pos, dir)
      symbol = get_symbol(grid, pos)
    end

    # If is a an unvisited position
    if symbol != :visited
      move = substract_positions(pos, me)
      distance = move[0].abs + move[1].abs

      movements << {
        :symbol => symbol,
        :position => pos,
        :duration => 1.0 * distance / speed
      }
    end
  end

  movements

end

def find_exit(grid, me, speed, stop_time, total_time = 0, best_time = Float::INFINITY)

  total_time += stop_time

  # Bound
  return best_time if total_time >= best_time

  next_movements(grid, me, speed).each do |movement|

    new_time = total_time + movement[:duration]

    if movement[:symbol] == :exit
      return new_time
    end

    pos = movement[:position]

    # Change cell status to visited
    grid[pos[0]][pos[1]] = :visited

    result = find_exit(grid, pos, speed, stop_time, new_time, best_time)

    if result < best_time
      best_time = result
    end

    # Restore cell status
    grid[pos[0]][pos[1]] = :ice
  end

  best_time

end

test_cases = process_input
test_cases.each { |test_case| puts find_exit(*test_case).round }