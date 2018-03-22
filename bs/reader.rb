require_relative 'types'

class Reader
  PARSE_REGEX = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
  def initialize(str)
    @tokens = tokenize(str)
    @pos = 0
  end

  def next
    @pos += 1
    @tokens[@pos - 1]
  end
  alias :read_token :next

  def peek
    @tokens[@pos]
  end

  def read
    return if @tokens.length == 0 || @tokens.length == @pos

    read_form
  end

  def unescape(str)
    str.gsub(/\./, {
      "\\\\" => "\\",
      "\\n" => "\n",
      "\\\"" => '"',
    })
  end

  def read_form
    case (token = read_token)
    when ";"; nil
    when "'"; [:quote, read_form]
    when "`"; [:quasiquote, read_form]
    when "~"; [:unquote, read_form]
    when "~@"; [:"splice-unquote", read_form]
    when "^"; meta = read_form; [:"with-meta", read_form, meta]
    when "@"; [:deref, read_form]
    when "("; [:list, read_list(List, ")")]
    when ")"; raise "unexpected token ']' found"
    when "["; [:list, read_list(Vector, "]")]
    when "{"; [:list, Hash[*read_list(List, "}")].map { |k, v| [k, v] }]
    when "}"; raise "unexpected token '}' found"
    else
      read_atom(token)
    end
  end

  def read_list(klass, last)
    ast = klass.new
    while peek != last
      if peek.nil?
        raise "unexpected '#{last}', got EOF"
      end
      ast.push(read_form)
    end

    if peek == last
      read_token
    end

    ast
  end

  def read_atom(token)
    case token
    when /^-?[0-9]+$/; token.to_i # integer
    when /^-?[0-9][0-9.]*$/; token.to_f # float
    when /^".*"$/; unescape(token) # string
    when /^:/; "\u029e" + token[1..-1] # keyword
    when "nil"; nil
    when "true"; true
    when "false"; false
    else
      token.to_sym # symbol
    end
  end

  def tokenize(str)
    # 1. [\s,]* ignore space and comma
    # 2. ~@ capture special char ~@
    # 3. [\[\]{}()'`~^@] capture [](){}'`
    # 4. "(?:\\.|[^\\"])*" capture things in quote "" expect for backslash
    # 5. [^\s\[\]{}('"`,;)]* capture space and special chars
    str.scan(PARSE_REGEX).flatten.select do |token|
      !token.empty? && token[0] != ';'
    end
  end
end
