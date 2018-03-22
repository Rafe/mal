
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
