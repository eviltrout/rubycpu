ACTIONMAP = {

    :mov => lambda { |vm| vm.src_to_dest {|dest, src| src} },

    :cmp => lambda do |vm|
      vm.memory[ ByteCode.flags_location] = 0
      result = vm.dest_value - vm.src_value
      if (result == 0)
        vm.zf = true
      elsif (result < 0)
        vm.sf = true
      end
      vm.eip += 3
    end,

    :nop => lambda { |vm| vm.eip += 1},

    :jmp => lambda { |vm| vm.eip = vm.dest_value },
    
    :mod => lambda do |vm|
      vm.rem = vm.dest_value.to_i % vm.src_value.to_i
      vm.eip += 3
    end,

    :rem => lambda { |vm| vm.change_dest {vm.rem} },
    :inc => lambda { |vm| vm.change_dest { |d| d+1 } } ,
    :dec => lambda { |vm| vm.change_dest { |d| d-1 } } ,
    :not => lambda { |vm| vm.change_dest { |d| ~d } } ,
    :add => lambda { |vm| vm.src_to_dest { |d, s| d+s } },
    :sub => lambda { |vm| vm.src_to_dest { |d, s| d-s } },
    :mul => lambda { |vm| vm.src_to_dest { |d, s| d*s } },
    :shl => lambda { |vm| vm.src_to_dest { |d, s| d<<s } },
    :shr => lambda { |vm| vm.src_to_dest { |d, s| d>>s } },
    
    :div => lambda do |vm|
      vm.src_to_dest do |dest, src|
        raise DivideByZero.new if src == 0
        dest / src
      end
    end,
    
    :and => lambda { |vm| vm.src_to_dest { |d, s| d & s } },
    :or  => lambda { |vm| vm.src_to_dest { |d, s| d | s } },
    :xor => lambda { |vm| vm.src_to_dest { |d, s| d ^ s } },
   
    :je  => lambda do |vm|
      vm.eip = vm.zf ? vm.dest_value : vm.eip + 2 
    end,

    :jne => lambda do |vm| 
      vm.eip = !vm.zf ? vm.dest_value : vm.eip + 2        
    end,

    :jl => lambda do |vm| 
        vm.eip = (vm.sf != vm.of) ? vm.dest_value : vm.eip + 2
    end,

    :jg => lambda do |vm| 
        vm.eip = (!vm.zf and (vm.sf == vm.of)) ? vm.dest_value : vm.eip + 2        
    end,

    :jle => lambda do |vm| 
        vm.eip = (vm.zf or (vm.sf != vm.of)) ? vm.dest_value : vm.eip + 2      
    end,

    :jge => lambda do |vm| 
        vm.eip = (vm.sf == vm.of) ? vm.dest_value : vm.eip + 2        
    end,

    :prn => lambda do |vm|
      vm.output(vm.dest_value.to_s)
      vm.eip += 2
    end ,

    :push => lambda do |vm|
      vm.push(vm.dest_value)
      vm.eip += 2        
    end,

    :pop => lambda do |vm|
      vm.esp += 1
      raise InvalidStack.new if vm.esp > vm.end_of_memory
      vm.change_dest { vm.memory[vm.esp] }
    end,

    :call => lambda do |vm|
        vm.push(vm.eip+2)
        vm.eip = vm.dest_value
    end,

    :ret => lambda do |vm|
      vm.esp +=1 
      raise InvalidStack.new if vm.esp > vm.end_of_memory
      vm.eip = vm.memory[vm.esp]
    end

}
