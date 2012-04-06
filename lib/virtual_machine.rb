require './lib/byte_code'

class VirtualMachine

  # Exceptions that can be raised by a program
  class InvalidProgram < Exception; end
  class InvalidStack < Exception; end
  class StackOverflow < Exception; end
  class DivideByZero < Exception; end

  # Operations executed
  attr_reader :op_count

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
    while eip < @buffer.size

      opcode = @buffer[eip]
      case ByteCode.opcodes_inverted[opcode & ByteCode.op_mask]
      when :mov
        src_to_dest {|dest, src| src}
      when :cmp
        @memory[ByteCode.flags_location] = 0

        result = (dest_value - src_value)
        if (result == 0) 
          self.zf = true
        elsif (result < 0)
          self.sf = true
        end

        self.eip += 3
      when :nop
        self.eip += 1
      when :jmp
        self.eip = dest_value
      when :mod
        self.rem = dest_value.to_i % src_value.to_i
        self.eip += 3
      when :rem
        change_dest {rem}
      when :inc
        change_dest {|dest| dest + 1}
      when :dec   
        change_dest {|dest| dest - 1}    
      when :not
        change_dest {|dest| ~dest}        
      when :add
        src_to_dest {|dest, src| dest + src}        
      when :sub
        src_to_dest {|dest, src| dest - src}
      when :mul
        src_to_dest {|dest, src| dest * src}
      when :shl
        src_to_dest {|dest, src| dest << src}
      when :shr
        src_to_dest {|dest, src| dest >> src}
      when :div
        src_to_dest do |dest, src|
          raise DivideByZero.new if src == 0
          dest / src
        end
      when :and
        src_to_dest {|dest, src| dest & src}
      when :or
        src_to_dest {|dest, src| dest | src}
      when :xor
        src_to_dest {|dest, src| dest ^ src}
      when :je
        self.eip = self.zf ? dest_value : eip + 2
      when :jne
        self.eip = !self.zf ? dest_value : eip + 2        
      when :jl
        self.eip = (self.sf != self.of) ? dest_value : eip + 2
      when :jg
        self.eip = (!self.zf and (self.sf == self.of)) ? dest_value : eip + 2        
      when :jle
        self.eip = (self.zf or (self.sf != self.of)) ? dest_value : eip + 2      
      when :jge  
        self.eip = (self.sf == self.of) ? dest_value : eip + 2        
      when :prn
        output(dest_value.to_s)
        self.eip += 2
      when :push
        push(dest_value)
        self.eip += 2        
      when :pop
        self.esp += 1
        raise InvalidStack.new if self.esp > @end_of_memory
        change_dest { @memory[self.esp] }
      when :call
        push(eip+2)
        self.eip = dest_value
      when :ret
        self.esp +=1 
        raise InvalidStack.new if self.esp > @end_of_memory
        self.eip = @memory[self.esp]
      else
        raise InvalidProgram, "Don't understand the opcode %b" % opcode
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

