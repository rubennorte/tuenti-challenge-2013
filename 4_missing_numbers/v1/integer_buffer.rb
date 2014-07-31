class IntegerBuffer

  def initialize(size)
    @values = Array.new(size)
    @offset = 0
  end

  def last
    @values[@offset]
  end

  def read
    return nil if @offset == @values.size
    value = @values[@offset]
    @offset += 1
    value
  end

  def write(value)
    return nil if @offset == @values.size
    @values[@offset] = value
    @offset += 1
    value
  end

  def rewind
    @offset = 0
  end

  def values
    @values
  end

  def values=(val)
    @values = val
    @offset = 0
  end

  def eof?
    @offset == @values.size || @values[@offset].nil?
  end

end