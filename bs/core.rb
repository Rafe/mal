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
    args.map { |str| printer._parse(str, true) }.join(" ")
  },
  :str => -> (*args) {
    args.map { |str| printer._parse(str, false) }.join(" ")
  },
  :prn => -> (*args) {
     puts args.map { |str| printer._parse(str, true) }.join(" ")
  },
  :println => -> (*args) {
     puts args.map { |str| printer._parse(str, false) }.join(" ")
  },
  :">" => -> (a, b) { a > b },
  :">=" => -> (a, b) { a >= b },
  :"<" => -> (a, b) { a < b },
  :"<=" => -> (a, b) { a <= b },
  :"<=>" => -> (a, b) { a <=> b },
  :list => -> (*args) { List.new(args) },
  :list? => -> (a) { a.is_a?(List) },
  :empty? => -> (a) { a.empty? },
  :count => -> (a) { a == nil ? 0 : a.length },
  :size => -> (a) { a == nil ? 0 : a.length },
  :"read-string" => -> (str) { Reader.new(str).read },
  :"slurp" => -> (name) { File.read(name) },
  :atom => -> (val) { Atom.new(val) },
  :atom? => -> (val) { val.is_a?(Atom) },
  :deref => -> (atom) { atom.val },
  :reset! => -> (atom, val) { atom.val = val },
  :swap! => -> (atom, fn, *args) { atom.val = fn.(atom.val, *args) },
  :cons => -> (a, b) { List.new(b.clone.unshift(a)) },
  :concat => -> (*args) { args ||= []; List.new(args.reduce(&:+)) },
}
