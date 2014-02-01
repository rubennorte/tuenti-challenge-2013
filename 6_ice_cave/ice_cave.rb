#!/usr/bin/env ruby
# encoding: utf-8

def char_to_symbol(char)
  case char
  when '·' then :ice
  when '#' then :rock
  when 'X' then :me
  when 'O' then :visited
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
  [-1, 0],  # NORTH
  [0, -1], # WEST
  [0, 1],  # EAST
  [1, 0]  # SOUTH
]

def get_symbol(grid, pos)
  if pos[0] < 0 || pos[0] >= grid.size ||
      pos[1] < 0 || pos[1] >= grid[0].size
    return nil
  end
  grid[pos[0]][pos[1]]
end

def set_symbol(grid, pos, symbol)
  grid[pos[0]][pos[1]] = symbol
end

def add_positions(pos, other_pos)
  [pos[0] + other_pos[0], pos[1] + other_pos[1]]
end

def substract_positions(pos, other_pos)
  [pos[0] - other_pos[0], pos[1] - other_pos[1]]
end

def can_come_from(grid, pos, prev_pos)
  return true if pos == prev_pos
  symbol = get_symbol(grid, pos)
  symbol == :rock || symbol.nil?
end

def next_movements(grid, me, prev_pos, speed, stop_time)

  movements = []

  DIRECTIONS.each do |dir|

    reverse_pos = dir.map { |val| -val }
    reverse_pos = add_positions(me, reverse_pos)

    next if !can_come_from(grid, reverse_pos, prev_pos)

    pos = add_positions(me, dir)
    symbol = get_symbol(grid, pos)

    next if symbol != :ice && symbol != :me

    duration = 1.0/speed
    stop = false
    if get_symbol(grid, reverse_pos) == :rock
      # if it's an stopped status
      duration += stop_time
      stop = true
    end
    if symbol == :me
      duration += stop_time
      stop = true
    end

    movements << {
      :symbol => symbol,
      :position => pos,
      :duration => duration,
      :stop => stop
    }
  end

  movements

end

def find_exit(grid, pos, speed, stop_time, total_time = 0, best_time = Float::INFINITY, prev_pos = nil)

  # Bound
  return best_time if total_time >= best_time

  next_movements(grid, pos, prev_pos, speed, stop_time).each do |movement|

    new_time = total_time + movement[:duration]
    return new_time if movement[:symbol] == :me

    new_pos = movement[:position]

    # Change new cell status to visited
    prev_cell = get_symbol(grid, new_pos)
    set_symbol(grid, pos, :visited) if movement[:stop]

    result = find_exit(grid, new_pos, speed, stop_time, new_time, best_time, pos)

    if result < best_time
      best_time = result
    end

    # Restore new cell status
    set_symbol(grid, new_pos, prev_cell)

  end

  best_time

end

test_cases = process_input
test_cases.each { |test_case| puts find_exit(*test_case).round }
