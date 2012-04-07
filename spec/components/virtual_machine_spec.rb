require 'spec_helper'
require 'virtual_machine'

describe VirtualMachine do

  before do
    # We only need tiny memory sizes for these tests. So let's speed it up
    VirtualMachine.memory_size = 20
    VirtualMachine.stack_size = 10
  end


  describe 'nop' do
    it 'does nothing' do
      VirtualMachine.execute("nop").op_count.must_equal 1
    end
  end

  describe 'mov' do
    it 'sets a value to a register' do
      VirtualMachine.execute('mov ebx, 3').ebx.must_equal 3
    end

    it 'sets a register to the value of another register' do
      VirtualMachine.execute("mov eax, 7
                              mov ecx, eax").ecx.must_equal 7
    end

    it 'can set offsets in memory' do
      VirtualMachine.execute("mov [100], 11
                              mov eax, [100]").eax.must_equal 11
    end

    it 'can move memory to memory' do
      VirtualMachine.execute("mov [100], 10
                              mov [101], [100]
                              mov ebx, [101]").ebx.must_equal 10
    end

    it 'can address by hex or decimal address' do
      VirtualMachine.execute("mov [10h], 123
                              mov eax, [16]").eax.must_equal 123
    end

  end

  describe 'add' do
    it 'adds 3 to ebx' do
      VirtualMachine.execute('mov ebx, 1
                              add ebx, 3').ebx.must_equal 4
    end

    it 'adds edx to eax' do
      VirtualMachine.execute("mov eax, 2
                              mov edx, 3
                              add eax, edx").eax.must_equal 5
    end

    it 'adds eax to eax' do
      VirtualMachine.execute("mov ecx, 1
                              add ecx, ecx").ecx.must_equal 2
    end    
  end  

  describe 'sub' do
    it 'subs 3 from ebx' do
      VirtualMachine.execute('mov ebx, 3
                              sub ebx, 1').ebx.must_equal 2
    end

    it 'subs edx from eax' do
      VirtualMachine.execute("mov eax, 3
                              mov edx, 2
                              sub eax, edx").eax.must_equal 1
    end

    it 'subs eax from eax' do
      VirtualMachine.execute("mov ecx, 11
                              sub ecx, ecx").ecx.must_equal 0
    end    
  end

  describe 'mul' do
    it 'multiplies ebx by 3' do
      VirtualMachine.execute('mov ebx, 1
                              mul ebx, 3').ebx.must_equal 3
    end

    it 'multiplies eax by edx' do
      VirtualMachine.execute("mov eax, 2
                              mov edx, 3
                              mul eax, edx").eax.must_equal 6
    end

    it 'squares ecx' do
      VirtualMachine.execute("mov ecx, 3
                              mul ecx, ecx").ecx.must_equal 9
    end    
  end  


  describe 'div' do
    it 'divides ebx by 3' do
      VirtualMachine.execute('mov ebx, 9
                              div ebx, 3').ebx.must_equal 3
    end

    it 'multiplies eax by edx' do
      VirtualMachine.execute("mov eax, 10
                              mov edx, 5
                              div eax, edx").eax.must_equal 2
    end

    it 'divides ecx by itself' do
      VirtualMachine.execute("mov ecx, 3
                              div ecx, ecx").ecx.must_equal 1
    end    

    it 'raises an error on divide by 0' do
      lambda {
        VirtualMachine.execute("mov eax, 10
                                mov ebx, 0
                                div eax, ebx")
      }.must_raise(VirtualMachine::DivideByZero)
    end    
  end  

  describe 'and' do
    it 'logical and of register to literal' do
      VirtualMachine.execute('mov ebx, 3
                              and ebx, 6').ebx.must_equal 2
    end

    it 'logical and of eax to edx' do
      VirtualMachine.execute("mov eax, 4
                              mov edx, 7
                              and eax, edx").eax.must_equal 4
    end

    it 'ands itself' do
      VirtualMachine.execute("mov ecx, 3
                              and ecx, ecx").ecx.must_equal 3
    end    
  end  

  describe 'or' do
    it 'logical or of register to literal' do
      VirtualMachine.execute('mov ebx, 3
                              or ebx, 6').ebx.must_equal 7
    end

    it 'logical or of eax to edx' do
      VirtualMachine.execute("mov eax, 4
                              mov edx, 7
                              or eax, edx").eax.must_equal 7
    end

    it 'ors itself' do
      VirtualMachine.execute("mov ecx, 3
                              or ecx, ecx").ecx.must_equal 3
    end    
  end 


  describe 'xor' do
    it 'logical xor of register to literal' do
      VirtualMachine.execute('mov ebx, 3
                              xor ebx, 6').ebx.must_equal 5
    end

    it 'logical xor of eax to edx' do
      VirtualMachine.execute("mov eax, 4
                              mov edx, 7
                              xor eax, edx").eax.must_equal 3
    end

    it 'xor itself' do
      VirtualMachine.execute("mov ecx, 3
                              xor ecx, ecx").ecx.must_equal 0
    end    
  end

  describe 'not' do
    it 'logical not of register' do
      VirtualMachine.execute('mov ebx, 1
                              not ebx').ebx.must_equal -2 
    end 
  end  

  describe 'shr' do
    it 'shift right of register to literal' do
      VirtualMachine.execute('mov ebx, 30
                              shr ebx, 2').ebx.must_equal 7
    end

    it 'shift right of register to register' do
      VirtualMachine.execute("mov eax, 64
                              mov edx, 3
                              shr eax, edx").eax.must_equal 8
    end

    it 'shifts itself right' do
      VirtualMachine.execute("mov ecx, 3
                              shr ecx, ecx").ecx.must_equal 0
    end    
  end

  describe 'shl' do
    it 'shift left of register to literal' do
      VirtualMachine.execute('mov ebx, 4
                              shl ebx, 2').ebx.must_equal 16
    end

    it 'shift left of register to register' do
      VirtualMachine.execute("mov eax, 3
                              mov edx, 4
                              shl eax, edx").eax.must_equal 48
    end

    it 'shifts itself left' do
      VirtualMachine.execute("mov ecx, 3
                              shl ecx, ecx").ecx.must_equal 24
    end    
  end

  describe 'push' do
    it 'changes the esp' do
      VirtualMachine.execute('push eax').stack_size.must_equal 1
    end
  end

  describe 'pop' do

    it 'raises an error when ret when the stack is empty' do
      -> { VirtualMachine.execute("pop eax") }.must_raise(VirtualMachine::InvalidStack)
    end

    it 'lowers the stack size' do
      vm = VirtualMachine.execute("push eax
                                   push eax
                                   push eax
                                   pop ebx").stack_size.must_equal 2
    end

    it 'can recover the value via pop' do
      VirtualMachine.execute("mov eax, 10
                              push eax
                              mov eax, 2
                              pop eax").eax.must_equal 10
    end

    it 'respects the push/pop order' do
      vm = VirtualMachine.execute("push 10
                                   push 15
                                   push 20
                                   pop eax
                                   pop ebx
                                   pop ecx")
      vm.eax.must_equal 20
      vm.ebx.must_equal 15
      vm.ecx.must_equal 10
    end

  end  

  describe 'stack overflow' do
    it 'raises a stack overflow error' do

      lambda {
      VirtualMachine.execute("top: push eax
                              jmp top")
      }.must_raise(VirtualMachine::StackOverflow)
    end
  end


  describe 'inc' do
    it 'increases the value in a register' do
      VirtualMachine.execute('mov ebx, 3
                              inc ebx').ebx.must_equal 4
    end

    it 'increases the value in a register' do
      VirtualMachine.execute('mov eax, 0
                              inc eax').eax.must_equal 1
    end
  end

  describe 'dec' do
    it 'decreases the value in a register' do
      VirtualMachine.execute('mov ecx, 3
                              dec ecx').ecx.must_equal 2
    end
  end  
 

  describe 'mod' do
    it 'divides two numbers and put the remainder in the remainder register' do
      VirtualMachine.execute('mod 10, 7').rem.must_equal 3
    end

    it 'has a modulo of 0' do
      VirtualMachine.execute('mod 5, 5').rem.must_equal 0
    end
  end

  describe 'rem' do
    it 'puts the remainder in ecx' do
      VirtualMachine.execute('mod 10, 3
                              rem ecx').ecx.must_equal 1
    end

    it 'puts the remainder in ebx' do
      VirtualMachine.execute('mod 1, 1
                              rem ebx').ebx.must_equal 0
    end    
  end



  describe 'jmp' do

    before do
      @vm = VirtualMachine.execute("jmp skip
                                    mov eax, 5
                                    skip: nop")
    end

    it 'skips the mov' do
      @vm.eax.must_equal 0
    end

    it 'is not executed according to the operation count' do
      @vm.op_count.must_equal 2
    end

  end

  describe 'cmp' do
    
    describe 'value to value' do
      describe 'equal' do
        before do 
          @vm = VirtualMachine.execute('cmp 11, 11')
        end

        it 'sets the zero flag' do
          @vm.zf.must_equal true
        end
      end

      describe 'greater than' do
        before do
          @vm = VirtualMachine.execute('cmp 8, 4')
        end

        it 'sets the zero flag to false' do
          @vm.zf.must_equal false
        end

        it 'sets the overflow flag to the sign flag' do
          @vm.sf.must_equal @vm.of
        end
      end

      describe 'less than' do
        before do
          @vm = VirtualMachine.execute('cmp 3, 6')
        end

        it 'sets the zero flag to false' do
          @vm.zf.must_equal false
        end

        it 'sets the overflow flag to the sign flag' do
          @vm.sf.wont_equal @vm.of
        end
      end

    end

    # Just make sure the basics work from registers too
    describe 'register to register' do
      it 'sets the zero flag to 1 when equal' do
        VirtualMachine.execute("mov eax, 1
                                mov ebx, 1
                                cmp eax, ebx").zf.must_equal true
      end

      it 'sets the zero flag to 0 when rinequal' do
        VirtualMachine.execute("mov eax, 1
                                mov ebx, 2
                                cmp eax, ebx").zf.must_equal false
      end      
    end

    describe 'register to value' do
      it 'sets the zero flag to 1 when equal' do
        VirtualMachine.execute("mov edx, 2
                                cmp edx, 2").zf.must_equal true
      end

      it 'sets the zero flag to 0 when inequal' do
        VirtualMachine.execute("mov edx, 2
                                cmp edx, 3").zf.must_equal false
      end      
    end    

  end

  describe "je" do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 1
                                      je equal
                                      mov eax, 2
                                      equal: nop"
      end

      it 'leaves eax as 1' do
        @vm.eax.must_equal 1
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end    
    end  

    describe 'when inequal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 9
                                      je equal
                                      mov eax, 2
                                      equal: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end

  end

  describe "jne" do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 1
                                      jne equal
                                      mov eax, 2
                                      equal: nop"
      end


      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end  

    describe 'when inequal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 9
                                      jne equal
                                      mov eax, 2
                                      equal: nop"
      end

      it 'leaves eax as 1' do
        @vm.eax.must_equal 1
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end 

    end

  end


  describe 'jl' do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 3
                                      jl less
                                      mov eax, 2
                                      less: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end

    describe 'when less than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 5
                                      jl less
                                      mov eax, 2
                                      less: nop"
      end

      it 'leaves eax as 1' do
        @vm.eax.must_equal 1
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end    
    end  

    describe 'when not less than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 2
                                      jl less
                                      mov eax, 2
                                      less: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end
  end

describe 'jg' do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 3
                                      jg more
                                      mov eax, 2
                                      more: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end

    describe 'when greater than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 4
                                      cmp eax, 1
                                      jg more
                                      mov eax, 2
                                      more: nop"
      end

      it 'leaves eax as 4' do
        @vm.eax.must_equal 4
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end    
    end  

    describe 'when not greater than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 3
                                      jg more
                                      mov eax, 2
                                      more: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end
  end


  describe 'jle' do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 3
                                      jle less
                                      mov eax, 2
                                      less: nop"
      end

      it 'leaves eax as 3' do
        @vm.eax.must_equal 3
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end      
    end

    describe 'when greater than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 5
                                      jle less
                                      mov eax, 2
                                      less: nop"
      end

      it 'leaves eax as 1' do
        @vm.eax.must_equal 1
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end    
    end  

    describe 'when not less than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 2
                                      jle less
                                      mov eax, 2
                                      less: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end

  end  

  describe 'jge' do

    describe 'when equal' do
      before do
        @vm = VirtualMachine.execute "mov eax, 3
                                      cmp eax, 3
                                      jge more
                                      mov eax, 2
                                      more: nop"
      end

      it 'leaves eax as 3' do
        @vm.eax.must_equal 3
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end      
    end

    describe 'when greater than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 5
                                      cmp eax, 1
                                      jge more
                                      mov eax, 2
                                      more: nop"
      end

      it 'leaves eax as 5' do
      end

      it 'executes fewer operations' do
        @vm.op_count.must_equal 4
      end    
    end  

    describe 'when not greater than' do
      before do
        @vm = VirtualMachine.execute "mov eax, 1
                                      cmp eax, 4
                                      jge more
                                      mov eax, 2
                                      more: nop"
      end

      it 'changes eax to 2' do
        @vm.eax.must_equal 2
      end

      it 'executes all the operations' do
        @vm.op_count.must_equal 5
      end    
    end

  end  

  describe 'call' do
    before do
      @vm = VirtualMachine.execute("call skip
                                    mov eax, 5
                                    skip: nop")
    end

    it 'skips the mov' do
      @vm.eax.must_equal 0
    end

    it 'pushes the return address onto the stack' do
      @vm.stack_size.must_equal 1
    end    

  end

  describe 'ret' do

    describe 'working example' do
      before do
        @vm = VirtualMachine.execute("call skip
                                      mov eax, 5
                                      jmp end
                                      skip: mov eax, 4
                                        ret
                                      end: nop")
      end

      it 'skips the mov' do
        @vm.eax.must_equal 5
      end

      it 'has an empty stack' do
        @vm.stack_size.must_equal 0
      end         
    end

    it 'raises an error when ret when the stack is empty' do
      -> { VirtualMachine.execute("ret") }.must_raise(VirtualMachine::InvalidStack)
    end

  end  



  describe 'prn' do

    it 'calls output with the value' do
      @vm = VirtualMachine.new(Compiler.compile("prn 1"))      
      @vm.expects(:output).with('1')
      @vm.run
    end

  end  

end

