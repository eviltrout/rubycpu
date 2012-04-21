class Action

  attr_reader :callon, :op, :block

  def initialize callon, op, &block
    @callon, @op = callon, op
    @block = block
  end

  def run
    @block.call( @callon )
  end

end

class ActionSet < Array

  attr_reader :vm, :setup_done

  def initialize( vm )
    @vm = vm
    @setup_done = false
  end

  def setup!
    self << Action.new( @vm, :mov ) { |obj| obj.src_to_dest {|dest, src| src} }
    self << Action.new( @vm, :cmp ) do |obj, mem| 
      obj.memory[ ByteCode.flags_location] = 0
      result = obj.dest_value - obj.src_value
      if (result == 0)
        obj.zf = true
      elsif (result < 0)
        @vm.sf = true
      end
      obj.eip += 3
    end
    self << Action.new( @vm, :nop ) { |obj| obj.eip += 1}
    self << Action.new( @vm, :jmp ) { |obj| obj.eip = obj.dest_value }
    self << Action.new( @vm, :mod ) do |obj| 
      obj.rem = obj.dest_value.to_i % obj.src_value.to_i
      obj.eip += 3
    end
    self << Action.new( @vm, :rem ) { |obj| obj.change_dest {obj.rem} }
    self << Action.new( @vm, :inc ) { |obj| obj.change_dest { |d| d+1 } } 
    self << Action.new( @vm, :dec ) { |obj| obj.change_dest { |d| d-1 } } 
    self << Action.new( @vm, :not ) { |obj| obj.change_dest { |d| ~d } } 
    self << Action.new( @vm, :add ) { |obj| obj.src_to_dest { |d, s| d+s } }
    self << Action.new( @vm, :sub ) { |obj| obj.src_to_dest { |d, s| d-s } }
    self << Action.new( @vm, :mul ) { |obj| obj.src_to_dest { |d, s| d*s } }
    self << Action.new( @vm, :shl ) { |obj| obj.src_to_dest { |d, s| d<<s } }
    self << Action.new( @vm, :shr ) { |obj| obj.src_to_dest { |d, s| d>>s } }
    self << Action.new( @vm, :div ) do |obj| 
      obj.src_to_dest do |dest, src|
        raise DivideByZero.new if src == 0
        dest / src
      end
    end
    self << Action.new( @vm, :and ) { |obj| obj.src_to_dest { |d, s| d & s } }
    self << Action.new( @vm, :or  ) { |obj| obj.src_to_dest { |d, s| d | s } }
    self << Action.new( @vm, :xor ) { |obj| obj.src_to_dest { |d, s| d ^ s } }
    self << Action.new( @vm, :je  ) do |obj| 
      obj.eip = obj.zf ? obj.dest_value : obj.eip + 2 
    end
    self << Action.new( @vm, :jne ) do |obj| 
      obj.eip = !obj.zf ? obj.dest_value : obj.eip + 2        
    end
    self << Action.new( @vm, :jl ) do |obj| 
        obj.eip = (obj.sf != obj.of) ? obj.dest_value : obj.eip + 2
    end
    self << Action.new( @vm, :jg ) do |obj| 
        obj.eip = (!obj.zf and (obj.sf == obj.of)) ? obj.dest_value : obj.eip + 2        
    end
    self << Action.new( @vm, :jle ) do |obj| 
        obj.eip = (obj.zf or (obj.sf != obj.of)) ? obj.dest_value : obj.eip + 2      
    end
    self << Action.new( @vm, :jge ) do |obj| 
        obj.eip = (obj.sf == obj.of) ? obj.dest_value : obj.eip + 2        
    end
    self << Action.new( @vm, :prn ) do |obj|
      obj.output(obj.dest_value.to_s)
      obj.eip += 2
    end 
    self << Action.new( @vm, :push ) do |obj|
      obj.push(obj.dest_value)
      obj.eip += 2        
    end
    self << Action.new( @vm, :pop ) do |obj|
      obj.esp += 1
      raise InvalidStack.new if obj.esp > obj.end_of_memory
      obj.change_dest { obj.memory[obj.esp] }
    end
    self << Action.new( @vm, :call ) do |obj|
        obj.push(obj.eip+2)
        obj.eip = obj.dest_value
    end
    self << Action.new( @vm, :ret ) do |obj|
      obj.esp +=1 
      raise InvalidStack.new if obj.esp > obj.end_of_memory
      obj.eip = obj.memory[obj.esp]
    end

    @setup_done = true
  end

  def run opcode
    raise "ActionSet was not setup!" unless @setup_done

    operation = ByteCode.opcodes_inverted[ opcode & ByteCode.op_mask ]
    action = self.find() { |action| action.op == operation }
    if action.nil?
      puts "An Error: operation: \"#{operation}\", opcode: \"#{opcode}\""
      raise VirtualMachine::InvalidProgram, "Don't understand the opcode %b" % opcode
    else
      action.run() 
    end
  end
end
