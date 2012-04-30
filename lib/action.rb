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
    super()
    @vm = vm
    @setup_done = false
  end

  def setup!( instruction_set )
    instruction_set.each_pair { |key, block| self << Action.new( @vm, key, &block ) }
    @setup_done = true
  end

end
