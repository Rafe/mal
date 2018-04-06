require_relative "mal_readline"
require_relative "reader"
require_relative "printer"
require_relative "env"
require_relative "types"
require_relative "core"

def pair?(obj)
  sequential?(obj) && obj.length > 0
end

def quasiquote(ast)
  if !pair?(ast)
    List.new [:quote, ast]
  elsif ast[0] == :unquote
    ast[1]
  elsif pair?(ast[0]) && ast[0][0] == :"splice-unquote"
    List.new [:concat, ast[0][1], quasiquote(ast.drop(1))]
  else
    List.new [:cons, quasiquote(ast[0]), quasiquote(ast.drop(1))]
  end
end

def macro_call?(ast, env)
  return false unless ast.is_a?(List) && ast[0].is_a?(Symbol)

  macro = env.find(ast[0])

  macro.is_a?(Function) && macro.is_macro
end

def macroexpand(ast, env)
  while macro_call?(ast, env)
    macro = env.get(ast[0])
    ast = macro[*ast[1..-1]]
  end
  return ast
end

def READ(str)
  Reader.new(str).read
end

def PRINT(exp)
  Printer.new.print(exp)
end

def EVAL(ast, env = nil)
  loop do
    if !ast.is_a? List
      return eval_ast(ast, env)
    end

    ast = macroexpand(ast, env)

    if !ast.is_a? List
      return eval_ast(ast, env)
    end
    return ast if ast.empty?

    case ast[0]
    when :def!, :defmacro!
      val = EVAL(ast[2], env)

      if ast[0] == :defmacro!
        val.is_macro = true
      end

      return env.set(ast[1], val)
    when :macroexpand
      return macroexpand(ast[1], env)
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
    when :quote
      return ast[1]
    when :quasiquote
      ast = quasiquote(ast[1])
    when :"try*"
      begin
        return EVAL(ast[1], env)
      rescue Exception => ex
        if ex.is_a? MalException
          ex = ex.data
        else
          ex = ex.message
        end

        handler = ast[2]
        if handler && handler[0] == :"catch*"
          return EVAL(handler[2], Env.new(env, [handler[1]], [ex]))
        else
          raise ex
        end
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

def RE(str)
  EVAL(READ(str), REPL_ENV)
end

def REP(str)
  PRINT(RE(str))
end

REPL_ENV.set(:eval, -> (ast) { EVAL(ast, REPL_ENV) })
RE <<-MAL
  (def! load-file (fn* (f) (eval (read-string (str "( do " (slurp f) ")")))))
MAL
RE <<-MAL
  (def! not (fn* (a) (if a false true)))
MAL
RE <<-MAL
  (defmacro! cond (fn* (& xs) (if (> (size xs) 0) (list 'if (first xs) (if (> (size xs) 1) (nth xs 1) (throw \"odd number of forms to cond\")) (cons 'cond (rest (rest xs)))))))
MAL
RE <<-MAL
  (defmacro! or (fn* (& xs) (if (empty? xs) nil (if (= 1 (size xs)) (first xs) `(let* (or_FIXME ~(first xs)) (if or_FIXME or_FIXME (or ~@(rest xs))))))))
MAL
RE("(def! *host-language* \"ruby\")")
RE("(def! *gensym-counter* (atom 0))")
RE("(def! gensym (fn* [] (symbol (str \"G__\" (swap! *gensym-counter* (fn* [x] (+ 1 x)))))))")
REPL_ENV.set(:"*ARGV*", List.new(ARGV.slice(1, ARGV.length) || []))

if ARGV.size > 0
  code = "(load-file \"" + ARGV[0] + "\")"
  PRINT(EVAL(READ(code), REPL_ENV))
  exit 0
end

RE("(println (str \"Mal [\" *host-language* \"]\"))")
while line = MalReadline.readline("user> ")
  begin
    REP(line)
  rescue Exception => e
    puts "Error: #{e}"
    puts "\t#{e.backtrace.join("\n\t")}"
  end
end
