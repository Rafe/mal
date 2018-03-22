require_relative "mal_readline"

def READ(str)
  str
end

def PRINT(exp)
  exp
end

def EVAL(ast, env = {})
  ast
end

def REP(str)
  PRINT(EVAL(READ(str)))
end

while line = MalReadline.readline("user> ")
  puts REP(line)
end
