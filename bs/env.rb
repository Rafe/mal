class Env
  attr_accessor :data, :outer
  def initialize(outer = nil, binds = [], args = [])
    @data = {}
    @outer = outer

    binds.each_index do |i|
      data[binds[i]] = args[i]
    end
  end

  def find(key)
    if data.key?(key)
      data[key]
    elsif outer
      outer.find(key)
    else
      nil
    end
  end

  def set(key, val)
    data[key] = val
  end

  def key?(key)
    data.key?(key)
  end

  def missing?(key)
    find(key).nil?
  end

  def get(key)
    if !missing?(key)
      find(key)
    else
      raise "exception: key #{key} does not found"
    end
  end
end
