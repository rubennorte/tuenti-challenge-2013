#!/usr/bin/env ruby
# encoding: utf-8

filename = File.join(File.dirname(__FILE__), 'boozzle-dict.txt')
$dictionary = File.readlines(filename).map(&:chomp).reverse # longer words first
$character_score = {
  "A" => 1, "C" => 3, "B" => 3, "E" => 1, "D" => 2, "G" => 2, "F" => 4,
  "I" => 1, "H" => 4, "K" => 5, "J" => 8, "M" => 3, "L" => 1, "O" => 1,
  "N" => 1, "Q" => 5, "P" => 3, "S" => 1, "R" => 1, "U" => 1, "T" => 1,
  "W" => 4, "V" => 4, "Y" => 4, "X" => 8, "Z" => 10
}

def process_input
  test_cases = []
  test_case_count = gets.to_i
  test_case_count.times do
    gets # skip score for each character
    duration = gets.to_i
    rows = gets.to_i
    columns = gets.to_i
    grid = Array.new(rows)

    char_frequency = {}
    char_frequency.default = 0

    rows.times do |row|
      row_data = gets.split(' ').each_with_index.map do |cell_data, column|
        char, type, multiplier = cell_data.split('')
        char_multiplier = 1
        word_multiplier = 1
        if type == '1'
          char_multiplier = multiplier.to_i
        else
          word_multiplier = multiplier.to_i
        end
        char_frequency[char] += 1
        {
          char: char,
          value: $character_score[char] * char_multiplier,
          word_multiplier: word_multiplier,
          # Support fields
          row: row,
          column: column,
          available: true
        }
      end
      grid[row] = row_data
    end

    test_cases << [grid, duration, $dictionary, char_frequency]
  end
  test_cases
end

def character_count(word)
  frequency = word.split('').group_by { |char| char }
  frequency.each_pair do |key, value|
    frequency[key] = value.size
  end
  frequency
end

def available_words(dictionary, max_length)
  dictionary.reject { |w| w.size > max_length }
end

def value_of(path)
  sum = path.reduce(0) do |memo, cell|
    memo + cell[:value]
  end

  multiplier = 1
  path.each do |cell|
    if cell[:word_multiplier] > multiplier
      multiplier = cell[:word_multiplier]
    end
  end

  sum * multiplier + path.size
end

def best_word_path(grid, word, path=[])

  return path if word.size == 0

  best = []
  best_value = 0

  check_cell = lambda { |cell|
    if cell[:char] == word[0] && cell[:available]
      cell[:available] = false
      result = best_word_path(grid, word[1..-1], path + [cell])
      cell[:available] = true

      value = value_of(result)

      if value > best_value
        best = result
        best_value = value
      end
    end
  }

  if path.size == 0
    grid.each do |row|
      row.each do |cell|
        check_cell.call(cell)
      end
    end
  else
    cell = path.last
    row = cell[:row]
    column = cell[:column]

    (-1..1).each do |row_dir|
      (-1..1).each do |column_dir|
        next if row_dir == 0 && column_dir == 0

        next_row = row + row_dir
        next_column = column + column_dir
        next if next_row < 0 || next_column < 0 ||
            next_row >= grid.size || next_column >= grid.first.size

        cell = grid[next_row][next_column]
        check_cell.call(cell) if cell
      end
    end
  end

  best

end

def best_score(grid, duration, dictionary, score, best_word_scores)

  max_length = duration-1 # minus the submit button pressing time

  best_score = score

  dictionary = available_words(dictionary, max_length)
  dictionary.each do |word|

    word_score = best_word_scores[word]
    if word_score.nil?
      word_path = best_word_path(grid, word)
      word_score = value_of(word_path)
      best_word_scores[word] = word_score
    end

    if word_score > 0
      new_score = best_score(grid, duration - word.size - 1, dictionary - [word], score + word_score, best_word_scores)
      best_score = new_score if new_score > best_score
    end

  end

  best_score

end

test_cases = process_input
test_cases.each do |test_case|
  grid, duration, dictionary, char_frequency = test_case

  # Filter by character frequency
  dictionary = dictionary.reject do |word|
    character_count(word).each_pair.any? do |pair|
      char_frequency[pair[0]] < pair[1]
    end
  end

  puts best_score(grid, duration, dictionary, 0, {})
end
