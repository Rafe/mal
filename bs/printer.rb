require_relative 'types'

class Printer
  def _parse(obj, print_readably=true)
    case obj
    when List
      "(" + obj.map { |x| _parse(x) }.join(" ") + ")"
    when Vector
      "[" + obj.map { |x| _parse(x) }.join(" ") + "]"
    when Hash
      ret = []
      obj.each { |k,v| ret.push(_parse(k), _parse(v)) }
      "{" + ret.join(" ") + "}"
    when String
      if obj[0] == "\u029e"
        ":" + obj[1..-1]
      elsif print_readably
        obj.inspect  # escape special characters
      else
        obj
      end
    when Atom
      "(atom " + _parse(obj.val, true) + ")"
    when nil
      "nil"
    else
      obj.to_s
    end
  end

  def print(exp)
    puts _parse(exp)
  end
end
