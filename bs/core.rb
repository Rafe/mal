require_relative "printer"
require_relative "types"

printer = Printer.new

def to_hash(args=[])
  Hash[args.each_slice(2).to_a]
end

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
  :size => -> (a) { a == nil ? 0 : a.size },
  :"read-string" => -> (str) { Reader.new(str).read },
  :"slurp" => -> (name) { File.read(name) },
  :atom => -> (val) { Atom.new(val) },
  :atom? => -> (val) { val.is_a?(Atom) },
  :deref => -> (atom) { atom.val },
  :reset! => -> (atom, val) { atom.val = val },
  :swap! => -> (atom, fn, *args) { atom.val = fn.(atom.val, *args) },
  :cons => -> (a, b) { List.new(b.clone.unshift(a)) },
  :concat => -> (*args) { args ||= []; List.new(args.reduce(&:+)) },
  :nth => -> (list, n) {
    raise "nth: index out of range" if n >= list.length
    list[n]
  },
  :first => -> (list=[]) { list.first },
  :last => -> (list=[]) { list.last },
  :rest => -> (list=[]) { list.drop(1) },
  :throw => -> (err) { raise MalException.new(err), "Mal Exception!" },
  :nil? => -> (val) { val.nil? },
  :true? => -> (val) { val == true },
  :false? => -> (val) { val == false },
  :symbol => -> (val) { val.to_sym },
  :symbol? => -> (val) { val.is_a? Symbol },
  :vector => -> (*args) { Vector.new(args) },
  :vector? => -> (vec) { vec.is_a?(Vector) },
  :"hash-map" => -> (*args) { to_hash(args) },
  :get => -> (map, key) { map[key] },
  :contains? => -> (map, key) { map.key?(key) },
  :keys => -> (map) { List.new(map.keys) },
  :vals => -> (map) { List.new(map.values) },
  :map => -> (fn, list) { list.map(&:fn) },
  :map? => -> (map) { map.is_a?(Hash) },
  :apply => -> (fn, *args, rest) { fn.(*args.concat(rest || [])) },
  :assoc => -> (map, *rest) {
    map.merge(to_hash(rest))
  },
  :dissoc => -> (map, *rest) {
    rest.reduce(map.clone) {|h, k| h.delete(k); h}
  },
}
