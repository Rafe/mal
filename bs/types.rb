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
  attr_accessor :ast, :env, :params, :is_macro

  def initialize(ast = nil, env = nil, params = nil, is_macro = false, &block)
    super()
    @ast = ast
    @env = env
    @params = params
    @is_macro = is_macro
  end

  def get_env(args)
    Env.new(@env, @params, args)
  end
end

class MalException < StandardError
  attr_accessor :data
  def initialize(data)
    @data = data
  end
end

def sequential?(obj)
  obj.is_a?(List) || obj.is_a?(Vector)
end
