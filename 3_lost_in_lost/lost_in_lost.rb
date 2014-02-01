#!/usr/bin/env ruby

# This problem is represented as a directed graph where:
#   - The scenes are the vertices
#   - The precedence of scenes are the edges. If a scene A happens before another
#     scene B then there is a edges that connect A with B.
# If exists any cycle in the graph then the script is invalid
# If exists a hamiltonian path in the graph (it can only exist one since the graph doesn't contain cycles), 
# then there's only one possible scene order
# Otherwise, the script is valid

# script = [
#   [".", "bla bla bla"],
#   ["<". "meh meh meh"],
#   ...
# ]
def get_script
  script = gets
  script.gsub!(/\n$/, '')

  script = script.gsub(/([.<>])/, '-\1').split('-')[1..-1]
  script = script.map { |scene| [scene[0], scene[1..-1]] }
  script
end

# edges = [
#   ["A", "B"] # "A" -> "B"
# ]
def get_edges(script)
  edges = []
  last_scene = nil
  script.each do |scene|
    case scene[0]
      when '.' then
        edges << [last_scene, scene[1]] if last_scene
        last_scene = scene[1]
      when '<' then
        edges << [scene[1], last_scene] if last_scene
      else
        edges << [last_scene, scene[1]] if last_scene
    end
  end
  edges
end

def get_vertices(edges)
  edges.flatten.uniq
end

def get_following(edges, vertex)
  list = []
  edges.each do |e|
    list << e[1] if e[0] == vertex
  end
  list
end

def get_precedent(edges, vertex)
  list = []
  edges.each do |e|
    list << e[0] if e[1] == vertex
  end
  list
end

def process(edges, vertices, path)

  # Return the path if it's complete
  return path if path.size == vertices.size

  last_scene = nil
  last_scene_is_complete = false
  solved = false

  adjacents = get_following(edges, path.last)
  adjacents.each do |vertex|

    # Check for cycles
    return 'invalid' if path.index(vertex)

    scene = process(edges, vertices, path + [vertex])
    
    # Propagate terminating results
    return 'invalid' if scene == 'invalid'
    return 'valid' if scene == 'valid'

    # The current path isn't a complete scene
    #next if scene.size < vertices.size

    scene_is_complete = scene.size == vertices.size
    if scene_is_complete and last_scene_is_complete
      return 'valid'
    end

    if scene_is_complete
      last_scene = scene
      last_scene_is_complete = true
    end
  end

  return last_scene || path
end

scripts = []
number_of_lines = gets.to_i
number_of_lines.times do
  scripts << get_script
end

scripts.each do |script|

  edges = get_edges(script)
  vertices = get_vertices(edges)

  # Check that there is only one possible beginning scene
  beginning_scenes = vertices.select { |v| get_precedent(edges, v).size == 0 }
  if beginning_scenes.size != 1
    puts "invalid"
    next
  end

  # Check that there is only one possible end scene
  end_scenes = vertices.select { |v| get_following(edges, v).size == 0 }
  if end_scenes.size != 1
    puts "invalid"
    next
  end

  initial_path = [beginning_scenes.first]
  result = process(edges, vertices, initial_path)
  if result == "invalid"
    puts "invalid"
  elsif result == "valid" || result.size != vertices.size
    puts "valid"
  else
    puts result.join(',')
  end

end