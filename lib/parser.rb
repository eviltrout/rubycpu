require 'treetop'
require 'polyglot'
require './lib/node_extensions'

class Parser
  
  class ParserException < Exception; end

  # Load the Treetop grammar from the 'sexp_parser' file, and create a new
  # instance of that parser as a class variable so we don't have to re-create
  # it every time we need to parse a string
  Treetop.load './lib/assembler'
  @@parser = AssemblerParser.new
  
  # Parse an input string and return a Ruby array like:
  #   [:this, :is, [:a, :test]]
  def self.parse(data)
    
    # Pass the data over to the parser instance
    tree = @@parser.parse(data + "\n")
    
    # If the AST is nil then there was an error during parsing
    # we need to report a simple error message to help the user
    if(tree.nil?)
      raise ParserException, "Parse error at offset: #{@@parser.index}"
    end

    # Remove all syntax nodes that aren't one of our custom
    # classes. If we don't do this we will end up with a *lot*
    # of essentially useless nodes
    self.clean_tree(tree)

    tree = tree.to_array

    include_includes( tree )
    # Convert the AST into an array representation of the input
    # structure and return it
    puts "#{tree}"
    return tree
  end

  def self.include_includes(tree)
    tree.map! do |node|
      if node.is_a? Assembler::IncludeInstruction
        tree.insert( tree.find_index(node), self.parse( File.read( node.text_value ) ) )
        tree.delete node
      else
        node
      end
    end
  end
  
  private
  
    def self.clean_tree(root_node)
      return if(root_node.elements.nil?)
      root_node.elements.delete_if{|node| node.class.name == "Treetop::Runtime::SyntaxNode" }
      root_node.elements.each {|node| self.clean_tree(node) }
    end

end
