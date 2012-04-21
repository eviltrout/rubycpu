require './lib/actionmap'

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
    ACTIONMAP.each_pair { |key, block| self << Action.new( @vm, key, &block ) }
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
