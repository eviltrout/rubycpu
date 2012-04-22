require './lib/byte_code'
require './lib/action'

class VirtualMachine

  # Exceptions that can be raised by a program
  class InvalidProgram < Exception; end
  class InvalidStack < Exception; end
  class StackOverflow < Exception; end
  class DivideByZero < Exception; end

  # Operations executed
  attr_reader :op_count, :end_of_memory, :memory

  # Memory map
  # [eax, ebx, ecx, edx, esp, ebp] [eip] [rem] [flags] .. [stack]

  def initialize(program)
    @memory = Array.new(VirtualMachine.memory_size)
    @end_of_memory = @memory.size-1
    @buffer = program.unpack('V*')
    
    # Initialize registers to 0
    ByteCode.registers.each {|r, o| @memory[o] = 0 }
    @memory[ByteCode.flags_location] = 0
    self.eip = 0
    self.rem = 0

    self.esp = @end_of_memory
    @stack_end = self.esp - VirtualMachine.stack_size
    @op_count = 0

    @actions = ActionSet.new(self)
    @actions.setup!
  end

  # Accessors for registers
  ByteCode.registers.each do |reg, offset|
    define_method(reg) { @memory[offset] }
    define_method("#{reg}=") {|val| @memory[offset] = val}
  end

  # Accessors for eip and rem
  %w(eip rem).each do |reg|
    class_eval %{
      def #{reg}; @memory[ByteCode.#{reg}_location]; end
      def #{reg}=(val); @memory[ByteCode.#{reg}_location] = val; end
    }
  end

  # Accessors for flags
  %w(zf sf of).each do |f|
    class_eval %{
      def #{f}; (@memory[ByteCode.flags_location] & ByteCode.#{f}_mask) == ByteCode.#{f}_mask; end
      def #{f}=(val)
        if val
          @memory[ByteCode.flags_location] |= ByteCode.#{f}_mask
        else
          @memory[ByteCode.flags_location] &= (~ByteCode.#{f}_mask)
        end
      end
    }
  end

  # For tuning the VM
  def self.memory_size=(sz)
    @memory_size = sz
  end

  def self.memory_size
    @memory_size || (1024 * 256)
  end

  # For tuning the VM
  def self.stack_size=(sz)
    @stack_size = sz
  end

  def self.stack_size
    @stack_size || (1024 * 4)
  end  

  def src_value
    opcode = @buffer[eip]
    src = @buffer[eip+2]
    if opcode & ByteCode.op_source_offset == ByteCode.op_source_offset
      @memory[src]
    else
      src
    end
  end

  def stack_size
    (@end_of_memory-self.esp)
  end

  def dest_value
    opcode = @buffer[eip]
    dest = @buffer[eip+1]
    if opcode & ByteCode.op_dest_offset == ByteCode.op_dest_offset
      @memory[dest]
    else
      dest
    end
  end  

  def output(value)
    puts value
  end

  def push(val)
    raise StackOverflow.new if self.esp < @stack_end    
    @memory[self.esp] = val
    self.esp -= 1
  end

  # Perform an operation and store it in the dest
  def src_to_dest
    change_dest {|dest| yield(dest, src_value.to_i)}
    self.eip += 1
  end

  # Change the destination
  def change_dest
    @memory[@buffer[eip+1]] = yield(dest_value.to_i)
    self.eip += 2
  end

  def run

    actionset = ActionSet.new( self )
    actionset.setup!

    while eip < @buffer.size
      opcode = @buffer[eip]
      operation = ByteCode.opcodes_inverted[ opcode & ByteCode.op_mask ]
      action = actionset.find() { |action| action.op == operation }

      if action.nil?
        puts "An Error: operation: \"#{operation}\", opcode: \"#{opcode}\""
        raise VirtualMachine::InvalidProgram, "Don't understand the opcode %b" % opcode
      else
        action.run() 
      end

      # Keep track of how many operations we've done
      @op_count += 1
      
    end
  end

  def self.execute(code)
    @vm = VirtualMachine.new(Compiler.compile(code))
    @vm.run
    @vm
  end

end

