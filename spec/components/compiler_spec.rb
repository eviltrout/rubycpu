require 'spec_helper'
require 'compiler'

describe Compiler do

  describe "nop" do
    it "compiles the instruction" do
      Compiler.compile_to_array("nop")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:nop])
    end
  end

  describe "ret" do
    it "compiles the instruction" do
      Compiler.compile_to_array("ret")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:ret])
    end
  end

  describe "mov" do
    it "compiles the mov instruction" do
      Compiler.compile_to_array("mov eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:mov])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("mov") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("mov eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('mov 3, eax') }.must_raise(Parser::ParserException)
    end


    describe 'literal to offset' do
      before do
        @data = Compiler.compile_to_array("mov [100], 7")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has offset as the destination" do
        @data[1].must_equal 100
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_value)
      end

      it "has 3 as the source literal" do
        @data[2].must_equal 7
      end      

    end


    describe 'literal to register' do
      before do
        @data = Compiler.compile_to_array("mov ebx, 3")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ebx]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_value)
      end

      it "has 3 as the source literal" do
        @data[2].must_equal 3
      end      
    end

    describe 'register to register' do
      before do
        @data = Compiler.compile_to_array("mov ecx, eax")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ecx]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_offset)
      end

      it "has 3 as the source register" do
        @data[2].must_equal ByteCode.registers[:eax]
      end  
    end

  end

  describe "cmp" do

    it "compiles the cmp instruction" do
      Compiler.compile_to_array("cmp eax, ecx")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:cmp])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("cmp") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("cmp eax") }.must_raise(Parser::ParserException)
    end   

    describe 'literal to register' do
      before do
        @data = Compiler.compile_to_array("cmp ecx, 1")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ecx]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_value)
      end

      it "has 3 as the source literal" do
        @data[2].must_equal 1
      end      
    end

    describe 'register to register' do
      before do
        @data = Compiler.compile_to_array("cmp eax, ebx")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:eax]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_offset)
      end

      it "has 3 as the source register" do
        @data[2].must_equal ByteCode.registers[:ebx]
      end  
    end

    describe "register to literal" do
      before do
        @data = Compiler.compile_to_array("cmp 7, ecx")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_value)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal 7
      end
    end

  end

  describe "add" do
    it "compiles the add instruction" do
      Compiler.compile_to_array("add eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:add])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("add") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("add eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('add 3, eax') }.must_raise(Parser::ParserException)
    end
  end

  describe "sub" do
    it "compiles the sub instruction" do
      Compiler.compile_to_array("sub eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:sub])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("sub") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("sub eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('sub 3, eax') }.must_raise(Parser::ParserException)
    end
  end


  describe "mul" do
    it "compiles the mul instruction" do
      Compiler.compile_to_array("mul eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:mul])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("mul") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("mul eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('mul 3, eax') }.must_raise(Parser::ParserException)
    end
  end

  describe "div" do
    it "compiles the div instruction" do
      Compiler.compile_to_array("div eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:div])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("div") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("div eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('div 3, eax') }.must_raise(Parser::ParserException)
    end

    it 'raises an exception when the divisor is 0' do
      -> { Compiler.compile('div eax, 0') }.must_raise(Parser::ParserException)
    end

    it "doesn't raise an exception when the divisor is 0 padded" do
      Compiler.compile('div eax, 0001')
    end    
  end  

  describe "and" do
    it "compiles the and instruction" do
      Compiler.compile_to_array("and eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:and])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("and") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("and eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('and 3, eax') }.must_raise(Parser::ParserException)
    end
  end  

  describe "or" do
    it "compiles the or instruction" do
      Compiler.compile_to_array("or eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:or])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("or") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("or eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('or 3, eax') }.must_raise(Parser::ParserException)
    end
  end   


  describe "xor" do
    it "compiles the xor instruction" do
      Compiler.compile_to_array("xor eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:xor])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("xor") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("xor eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('xor 3, eax') }.must_raise(Parser::ParserException)
    end
  end  

  describe "not" do
    it "compiles the not instruction" do
      Compiler.compile_to_array("not eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:not])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("not") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('not 3') }.must_raise(Parser::ParserException)
    end
  end  

  describe "shl" do
    it "compiles the shl instruction" do
      Compiler.compile_to_array("shl eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:shl])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("shl") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("shl eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('shl 3, eax') }.must_raise(Parser::ParserException)
    end
  end  

  describe "shr" do
    it "compiles the shr instruction" do
      Compiler.compile_to_array("shr eax, 10")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:shr])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("shr") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("shr eax") }.must_raise(Parser::ParserException)
    end    

    it 'raises an exception when the destination is a literal' do
      -> { Compiler.compile('shr 3, eax') }.must_raise(Parser::ParserException)
    end
  end    


  describe "mod" do

    it "compiles the mod instruction" do
      Compiler.compile_to_array("mod eax, ebx")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:mod])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("mod") }.must_raise(Parser::ParserException)
    end

    it 'raises an exception without a second parameters' do
      -> { Compiler.compile("mod eax") }.must_raise(Parser::ParserException)
    end  

    describe 'literal to register' do
      before do
        @data = Compiler.compile_to_array("mod eax, 8")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has eax as the dest register" do
        @data[1].must_equal ByteCode.registers[:eax]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_value)
      end

      it "has 3 as the source literal" do
        @data[2].must_equal 8
      end      
    end

    describe 'register to register' do
      before do
        @data = Compiler.compile_to_array("mod edx, eax")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has edx as the dest register" do
        @data[1].must_equal ByteCode.registers[:edx]
      end

      it "has a literal as the source" do
        @data[0].must_have_mask(ByteCode.op_source_offset)
      end

      it "has 3 as the source register" do
        @data[2].must_equal ByteCode.registers[:eax]
      end  
    end

    describe "register to literal" do
      before do
        @data = Compiler.compile_to_array("mod 3, eax")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_value)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal 3
      end
    end

  end


  describe "rem" do

    it "compiles the rem instruction" do
      Compiler.compile_to_array("rem eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:rem])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("rem") }.must_raise(Parser::ParserException)
    end   

    it 'raises an exception with a literal as the parameter' do
      -> { Compiler.compile("rem 8") }.must_raise(Parser::ParserException)
    end

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("rem ecx")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ecx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ecx]
      end
    end

  end

  describe "inc" do

    it "compiles the inc instruction" do
      Compiler.compile_to_array("inc eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:inc])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("inc") }.must_raise(Parser::ParserException)
    end   

    it 'raises an exception with a literal as the parameter' do
      -> { Compiler.compile("inc 8") }.must_raise(Parser::ParserException)
    end

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("inc ebx")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ebx]
      end
    end

  end  

  describe "dec" do

    it "compiles the dec instruction" do
      Compiler.compile_to_array("dec eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:dec])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("dec") }.must_raise(Parser::ParserException)
    end   

    it 'raises an exception with a literal as the parameter' do
      -> { Compiler.compile("dec 8") }.must_raise(Parser::ParserException)
    end

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("dec ebx")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebx as the dest register" do
        @data[1].must_equal ByteCode.registers[:ebx]
      end
    end

  end   

  describe 'push' do
    it "compiles the push instruction" do
      Compiler.compile_to_array("push eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:push])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("push") }.must_raise(Parser::ParserException)
    end   

    it 'allows us to push a literal' do
      Compiler.compile("push 8")
    end

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("push ebp")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has ebp as the dest register" do
        @data[1].must_equal ByteCode.registers[:ebp]
      end
    end
  end

  describe 'pop' do
    it "compiles the pop instruction" do
      Compiler.compile_to_array("pop eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:pop])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("pop") }.must_raise(Parser::ParserException)
    end   

    it 'allows us to pop a literal' do
      Compiler.compile("pop 8")
    end

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("pop esp")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has esp as the dest register" do
        @data[1].must_equal ByteCode.registers[:esp]
      end
    end
  end  


  describe "prn" do

    it "compiles the prn instruction" do
      Compiler.compile_to_array("prn eax")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:prn])
    end

    it 'raises an exception without any parameters' do
      -> { Compiler.compile("prn") }.must_raise(Parser::ParserException)
    end   

    describe 'register' do
      before do
        @data = Compiler.compile_to_array("prn eax")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_offset)
      end

      it "has eax as the dest register" do
        @data[1].must_equal ByteCode.registers[:eax]
      end
    end

    describe 'literal' do
      before do
        @data = Compiler.compile_to_array("prn 5")
      end

      it "has a register as the destination" do
        @data[0].must_have_mask(ByteCode.op_dest_value)
      end

      it "has eax as the dest register" do
        @data[1].must_equal 5
      end
    end    

  end  

  describe "labels" do

    it "allows us to compile code with a label" do
      Compiler.compile_to_array("hello: mov eax, 3")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:mov])
    end

    describe 'start label' do
      before do
        @code = Compiler.compile_to_array("mov eax, 3
                                           start: nop")
      end

      it 'inserts a jmp to the start label' do
        @code[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jmp])
      end

      it 'inserts a jmp to the start label' do
        @code[1].must_equal 5
      end
    end


    describe 'offsets' do
      it 'has the correct offset for jumping to the top' do
        Compiler.compile_to_array("hello: jmp hello")[1].must_equal 0
      end

     it 'has the offset of labels declared after the jmp statement' do
        Compiler.compile_to_array("jmp second\nsecond: nop")[1].must_equal 2
      end
    end

    describe 'jmp' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jmp hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jmp])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jmp") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jmp doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end


    describe 'call' do
      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: call hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:call])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("call") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("call doesnt_exist") }.must_raise(Compiler::CompilerException)
      end      
    end


    describe 'je' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: je hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:je])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("je") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("je doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end    

    describe 'jl' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jl hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jl])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jl") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jl doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end     

    describe 'jle' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jle hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jle])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jle") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jle doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end    

    describe 'jg' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jg hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jg])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jg") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jg doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end

    describe 'jge' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jge hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jge])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jge") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jge doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end

    describe 'jne' do

      it 'should have the correct operation' do
        Compiler.compile_to_array("hello: jne hello")[0].must_contain_bits(ByteCode.op_mask, ByteCode.opcodes[:jne])
      end

      it 'raises an exception without any parameters' do
        -> { Compiler.compile("jne") }.must_raise(Parser::ParserException)
      end   

      it "raises an exception when we try to jump to a label that doesn't exist" do
        -> { Compiler.compile("jne doesnt_exist") }.must_raise(Compiler::CompilerException)
      end

    end

  end


end
