require_relative "mal_readline"
require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "types"
require_relative "core"

def READ(str)
  Reader.new(str).read
end

def PRINT(exp)
  Printer.new.print(exp)
end

def EVAL(ast, env = nil)
  #puts "EVAL: #{Printer.new.print(ast)}"
  loop do
    if !ast.is_a? List
      return eval_ast(ast, env)
    end

    return ast if ast.empty?

    case ast[0]
    when :def!
      return env.set(ast[1], EVAL(ast[2], env))
    when :"let*"
      let_env = Env.new(env)
      ast[1].each_slice(2) do |k, e|
        let_env.set(k, EVAL(e, let_env))
      end

      env = let_env
      ast = ast[2]
    when :do
      eval_ast(ast[1..-2], env)
      ast = ast.last
    when :if
      cond = EVAL(ast[1], env)
      ast = cond ? ast[2] : ast[3]
    when :"fn*"
      return Function.new(ast[2], env, ast[1]) do |*args|
        EVAL(ast[2], Env.new(env, ast[1], List.new(args)))
      end
    else
      elements = eval_ast(ast, env)
      fn = elements[0]
      if fn.is_a?(Function)
        ast = fn.ast
        env = fn.get_env(elements.drop(1))
      else
        return fn[*elements.drop(1)]
      end
    end
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
  REP(line)
end
