require './lib/virtual_machine.rb'
require './lib/compiler.rb'

if ARGV.size < 1
  puts "Usage: #{$0} filename"
  exit(1)
end

code = Compiler.compile(File.read(ARGV[0]))
vm = VirtualMachine.new(code)
vm.run


