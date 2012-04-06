require './lib/parser'
require './lib/byte_code'

module Compiler

  class CompilerException < Exception; end;

  def self.compile_file(file)
    compile(File.read(file))
  end

  def self.compile_to_array(input)
    compile(input).unpack('V*')
  end

  def self.compile(input)

    buffer = []

    label_offsets = {}
    label_uses = {}


    parser = Parser.parse(input)

    # Add a jmp to start if the start label is present
    prepend_jump = nil
    parser.each do |line|
      if line[0].is_a?(Assembler::Label) and line[0].value == 'start'
        prepend_jump = line[0]
        break
      end
    end
    parser.unshift([:jmp, prepend_jump]) unless prepend_jump.nil?

    # Do our main compilation
    parser.each do |line|
      label = nil
      offset = buffer.size

      if line[0].is_a?(Assembler::Label)
        label = line[0]
        line = line[1..-1]
      end

      label_offsets[label.value] = offset unless label.nil?        

      line[0] = ByteCode.opcodes[line[0]] || ByteCode.opcodes[:nop]
      if line.size > 1

        if line[1].is_a?(Assembler::Offset)
          line[1] = line[1].value
          line[0] |= ByteCode.op_dest_offset          
        else          
          if line[1].is_a?(Assembler::Label)
            label = line[1].value
            label_uses[label] ||= []
            label_uses[label] << (offset+1)
            line[1] = 0
          end

          line[0] |= ByteCode.op_dest_value
        end

        # Second parameter
        if line.size > 2          
          if line[2].is_a?(Assembler::Offset)
            line[0] |= ByteCode.op_source_offset
            line[2] = line[2].value
          else
            line[0] |= ByteCode.op_source_value
          end
        end

      end
      buffer.concat(line)

    end

    # Second pass: Replace labels
    label_uses.each do |label, uses|
      offset = label_offsets[label]
      raise CompilerException, "Label #{label} was not defined" if offset.nil?
      uses.each do |idx|
        buffer[idx] = offset
      end      
    end

    buffer.pack('V*')
  end

end
