require './lib/actionmap'

class Action

  attr_reader :call_on, :block

  def initialize call_on, &block
    @call_on = call_on
    @block = block
  end

  def run
    @block.call( @call_on )
  end

end

class ActionMap < Hash

  attr_reader :vm, :setup_done

  def initialize( vm )
    super()
    @vm = vm
    @setup_done = false
  end

  def setup!( instruction_set )
    instruction_set.each_pair do |key, block|
      self[ key ] = Action.new( @vm, &block )
    end
    @setup_done = true
  end

end
