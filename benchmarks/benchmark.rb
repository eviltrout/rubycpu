if ARGV[0].nil? then puts "Usage: ruby benchmark.rb <asmfile>"; exit 1 end

require 'benchmark'
require './lib/virtual_machine.rb'
require './lib/compiler.rb'

puts "Compiling..."
puts Benchmark.measure { @code = Compiler.compile(File.read(ARGV[0])) }

@vm = VirtualMachine.new( @code )

puts "Running..."
puts Benchmark.measure { @vm.run }
