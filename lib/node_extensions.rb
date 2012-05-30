module Assembler

  class Label
    attr_reader :value
    def initialize(value)
      @value = value.strip
    end
  end

  class Offset
    attr_reader :value
    def initialize(value)
      @value = value.to_i
    end
  end

  class Lines < Treetop::Runtime::SyntaxNode
    def to_array
      self.elements.map do |e|
        val = e.to_array
        val.flatten! if val.is_a?(Array)
        val
      end
      
    end
  end

  class Container < Treetop::Runtime::SyntaxNode
    def to_array
      self.elements.map {|x| x.to_array}
    end    
  end

  # Instructions

  class Instruction < Treetop::Runtime::SyntaxNode
    def to_array
      name = self.class.name.gsub!(/Assembler\:\:/, '').gsub!(/Instruction$/, '').downcase!.to_sym

      if self.elements.nil?
        name
      else
        [name, self.elements.map {|x| x.to_array}].flatten
      end
    end
  end

  class NopInstruction < Instruction; end;
  class MovInstruction < Instruction; end;
  class ModInstruction < Instruction; end;
  class CmpInstruction < Instruction; end;
  class JeInstruction < Instruction; end;
  class JmpInstruction < Instruction; end;
  class JlInstruction < Instruction; end;
  class JleInstruction < Instruction; end;
  class JneInstruction < Instruction; end;
  class JgInstruction < Instruction; end;  
  class JgeInstruction < Instruction; end;    
  class IncInstruction < Instruction; end;
  class DecInstruction < Instruction; end;
  class MulInstruction < Instruction; end;
  class DivInstruction < Instruction; end;
  class RemInstruction < Instruction; end;
  class PrnInstruction < Instruction; end;
  class AddInstruction < Instruction; end;
  class SubInstruction < Instruction; end;  
  class PushInstruction < Instruction; end;
  class PopInstruction < Instruction; end;
  class CallInstruction < Instruction; end;
  class RetInstruction < Instruction; end;

  class AndInstruction < Instruction; end;
  class NotInstruction < Instruction; end;
  class OrInstruction < Instruction; end;
  class XorInstruction < Instruction; end;
  class ShlInstruction < Instruction; end;
  class ShrInstruction < Instruction; end;

  class IncludeInstruction < Instruction; end;
  
  # Literals and Registers

  class IntegerLiteral < Treetop::Runtime::SyntaxNode
    def to_array
      self.text_value.to_i
    end
  end

  class LabelLiteral < Treetop::Runtime::SyntaxNode
    def to_array
      Label.new(self.text_value)
    end
  end

  class Register < Treetop::Runtime::SyntaxNode
    def to_array
      Offset.new(ByteCode.registers[self.text_value.to_sym])
    end
  end

  class OffsetLiteral < Treetop::Runtime::SyntaxNode
    def to_array
      val = self.text_value.gsub(/\[|\]/, '')

      # If it's a hex value, convert it
      if val =~ /[0-9a-f]+h/
        val = val[0..-2].to_i(16)
      else
        val = val.to_i        
      end 

      Offset.new(val)
    end
  end  

end
