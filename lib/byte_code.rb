module ByteCode
  
  def self.opcodes
    {nop:  0x0000,
     mov:  0x0001, 
     cmp:  0x0002, 
     jmp:  0x0003, 
     je:   0x0004, 
     mod:  0x0005, 
     rem:  0x0006,
     inc:  0x0007, 
     prn:  0x0008, 
     jl:   0x0009, 
     jle:  0x000A, 
     jg:   0x000B, 
     jge:  0x000C, 
     jne:  0x000D,
     add:  0x000E,
     sub:  0x000F,
     push: 0x0010,
     pop:  0x0011,
     call: 0x0012,
     ret:  0x0013,
     dec:  0x0014,
     mul:  0x0015,
     div:  0x0016,
     and:  0x0017,
     not:  0x0018,
     or:   0x0019,
     xor:  0x001A,
     shl:  0x001B,
     shr:  0x001C} 
  end

  def self.opcodes_inverted
    @opcodes_inverted ||= opcodes.invert
  end

  def self.op_mask
    0x00FF
  end

  def self.op_source_offset
    0x0100
  end

  def self.op_source_value
    0x0200
  end

  def self.op_dest_offset
    0x0400
  end

  def self.op_dest_value
    0x0800
  end

  def self.registers
    {eax: 0x0,
     ebx: 0x1,
     ecx: 0x2,
     edx: 0x3,
     esp: 0x4,
     ebp: 0x5}    
  end

  def self.eip_location
    0x6
  end

  def self.rem_location
    0x7
  end

  def self.flags_location
    0x8
  end

  def self.zf_mask
    0x0001
  end

  def self.sf_mask
    0x0002
  end

  def self.of_mask
    0x0004
  end

end
