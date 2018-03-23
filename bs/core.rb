require_relative "printer"
require_relative "types"

printer = Printer.new

MAL_CORE = {
  :+ => -> (*args) { args.reduce(&:+) },
  :- => -> (a, b) { a - b },
  :* => -> (a, b) { a * b },
  :/ => -> (a, b) { a / b },
  :% => -> (a, b) { a % b },
  :** => -> (a, b) { a ** b },
  :"=" => -> (a, b) { a == b },
  :"pr-str" => -> (*args) {
    args.map { |str| printer._parse(str) }.join(" ")
  },
  :">" => -> (a, b) { a > b },
  :">=" => -> (a, b) { a >= b },
  :"<" => -> (a, b) { a < b },
  :"<=" => -> (a, b) { a <= b },
  :"<=>" => -> (a, b) { a <=> b },
  :list => -> (*args) { List.new(args) },
  :list? => -> (a) { a.is_a?(List) },
  :empty? => -> (a) { a.empty? },
  :count => -> (a) { a ==nil ? 0 : a.length },
  :size => -> (a) { a ==nil ? 0 : a.length },
}

MAL_CORE[:str] = MAL_CORE[:"pr-str"]
MAL_CORE[:prn] = MAL_CORE[:"pr-str"]
MAL_CORE[:println] = MAL_CORE[:"pr-str"]
MAL_CORE[:puts] = MAL_CORE[:"pr-str"]

