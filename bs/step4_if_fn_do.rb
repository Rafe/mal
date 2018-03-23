require_relative "mal_readline"
require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "types"
require_relative "core"
require 'pry'

def READ(str)
  Reader.new(str).read
end

def PRINT(exp)
  Printer.new.print(exp)
end

def EVAL(ast, env = nil)
  #puts "EVAL: #{Printer.new.print(ast)}"

  if !ast.is_a? List
    return eval_ast(ast, env)
  end

  return ast if ast.empty?

  case ast[0]
  when :def!
    env.set(ast[1], EVAL(ast[2], env))
  when :"let*"
    let_env = Env.new(env)
    ast[1].each_slice(2) do |k, e|
      let_env.set(k, EVAL(e, let_env))
    end

    EVAL(ast[2], let_env)
  else
    elements = eval_ast(ast, env)
    fn = elements[0]
    fn[*elements.drop(1)]
  end
end

def eval_ast(ast, env)
  case ast
  when Symbol
    if env.missing?(ast)
      raise "'function key #{ast}' does not exist"
    end
    env.find(ast)
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

REPL_ENV = MAL_CORE.reduce(Env.new) do |e, (k, v)|
  e.set(k, v)
  e
end

def REP(str)
  PRINT(EVAL(READ(str), REPL_ENV))
end

while line = MalReadline.readline("user> ")
  puts REP(line)
end
