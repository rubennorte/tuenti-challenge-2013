#!/usr/bin/env ruby

file = ARGV.first
raise 'Debes indicar el nombre del reto' if file.nil?
file = file += '.rb' if !file.end_with?('.rb')

template = <<TEMPLATE
#!/usr/bin/env ruby

while line = gets do
  # DO SOMETHING

  # PUTS SOMETHING
end

TEMPLATE

raise 'El archivo ya existe' if File.exists?(file)
File.open(file, 'w') {|f| f.write(template) }
File.chmod(0766, file)