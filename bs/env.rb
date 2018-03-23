class Env
  attr_accessor :data, :outer
  def initialize(outer = nil)
    @data = {}
    @outer = outer
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
    !find(key)
  end

  def get(key)
    if val = data.find(key)
      val
    else
      raise "exception: key #{key} does not found"
    end
  end
end
