class List < Array
end

class Vector < Array
end

class Atom
  attr_accessor :val
  def initialize(val)
      @val = val
  end
end

class Function < Proc
  attr_accessor :ast, :env, :params

  def initialize(ast = nil, env = nil, params = nil, &block)
    super()
    @ast = ast
    @env = env
    @params = params
  end

  def get_env(args)
    Env.new(@env, @params, args)
  end
end

def sequential?(obj)
  obj.is_a?(List) || obj.is_a?(Vector)
end
