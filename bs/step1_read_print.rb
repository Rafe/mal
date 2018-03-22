require_relative "mal_readline"
require_relative "reader"
require_relative "printer"

def READ(str)
  Reader.new(str).read
end

def PRINT(exp)
  Printer.new.print(exp)
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
