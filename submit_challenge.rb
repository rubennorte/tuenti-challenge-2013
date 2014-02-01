#!/usr/bin/env ruby

token = ARGV[0]
raise 'Debes indicar el token del reto' if token.nil? || token.empty?

file = ARGV[1]
raise 'Debes indicar el archivo ejecutable del reto' if file.nil? || file.empty?

source = File.expand_path(file)
scripts_dir = File.join(File.dirname(source), 'tools-python-2012-4')
test_command = File.join(scripts_dir, 'test_challenge.py')
submit_command = File.join(scripts_dir, 'submit_challenge.py')

ok = system("#{test_command} #{token} #{source}")
exit unless ok

archive = "#{source[0..-4]}.tgz"
ok = system("tar cvzf #{archive} #{source} &>/dev/null")
exit unless ok

system("#{submit_command} #{token} #{archive} #{source}")