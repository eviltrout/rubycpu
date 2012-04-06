# rubycpu

rubycpu is a virtualized CPU that's similar to x86 written in ruby. 

The goal of the project was to learn how to implement a bytecode compiler and interpreter, not performance.

The project includes an assembler compiler and virtual machine that interprets the compiled bytecode, as well as a comprehensive test suite.

### Trying it out

1. `bundle install` to install necessary gems.
2. `ruby run.rb asm/fib.asm` to run the fibonacci sample program.

### CPU Design

All values in the CPU are 32-bit, little endian and unsigned.

You can configure how much memory the Virtual Machine has and its stack size using class methods:

```ruby
  VirtualMachine.memory_size = 1000
  VirtualMachine.stack_size = 200
```

There are 4 general purpose registers: *eax*, *ebx*, *ecx* and *edx*. 

The stack pointer and base pointer are available as *esp* and *ebp*.

### Instruction Set

The instruction set is somewhat close to x86 assembly language. The [Wikibooks](http://en.wikibooks.org/wiki/X86_Assembly) articles on the language are excellent. Right now the following instructions are supported:

General:

* nop
* mov
* cmp
* push
* pop

Arithmetic:

* inc
* add
* sub
* dec
* mul
* div
* mod
* rem

Jumping/Calling:

* jmp
* call
* ret
* je
* jl 
* jle
* jg
* jge
* jne  

Bit Functions:

* and
* not
* or 
* xor
* shl
* shr

Special:

* prn (outputs the value of the register or memory to STDOUT)

### Machine Layout

All registers are mapped to addresses in memory and can be accessed directly. 

```
+---+---+---+---+---+---+---+---+-----+---+---+---+---+---------+
|eax|ebx|ecx|edx|esp|ebp|eip|rem|flags|...|...|...|...|stack end|
+---+---+---+---+---+---+---+---+-----+---+---+---+---+---------+
  0   1   2   3   4   5   6   7    8        ...         mem_size
```

You can use square brackets around an integer to access any address of mapped memory. This means that:

```
  mov ebx, 13
  mov edx, 20
```

is equivalent to:

```
  mov [1], 13
  mov [3], 20
```

The stack begins at the end of memory and goes downwards until `VirtualMachine.stack_size` is exhausted.


### Running the Tests

There are specs for compiling and running every command the CPU is capable of. Simply run `rake test` to execute the entire suite.
 
 
### Acknowledgments

* The [tinyvm](https://github.com/GenTiradentes/tinyvm) project was a great inspiration, in fact many of the sample programs were lifted directly from them. Thanks! 

* [@notch](http://twitter.com/notch)'s tweets about designing a CPU that inspired the project.

* My former co-worker [@aronmgough](http://twitter.com/aaronmgough)'s excellent [tutorial on treetop](http://thingsaaronmade.com/blog/a-quick-intro-to-writing-a-parser-using-treetop.html) which inspired my parser.

### License

rubycpu is released under the MIT License.

