require_relative "mal_readline"
require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "types"
require 'pry'

def READ(str)
  Reader.new(str).read
end

def PRINT(exp)
  Printer.new.print(exp)
end

def EVAL(ast, env = {})
  #puts "EVAL: #{Printer.new.print(ast)}"

  if ast.is_a? List
    return ast if ast.empty?

    elements = eval_ast(ast, env)
    fn = elements[0]
    fn[*elements.drop(1)]
  else
    eval_ast(ast, env)
  end
end

def eval_ast(ast, env)
  case ast
  when Symbol
    if !env.has_key?(ast)
      raise "'function key #{ast}' does not exist"
    end
    env[ast]
  when List
    List.new(ast.map{|a| EVAL(a, env)})
  when Vector
    Vector.new(ast.map{|a| EVAL(a, env)})
  when Hash
    ast.reduce({}) do |hash, k, v|
      hash[EVAL(k, env)] = EVAL(v, env)
      hash
    end
  else
    ast
  end
end

def REP(str)
  PRINT(EVAL(READ(str), REPL_ENV))
end

while line = MalReadline.readline("user> ")
  puts REP(line)
end
