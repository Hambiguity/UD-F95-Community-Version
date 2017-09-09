class << Marshal
  alias_method(:th_core_load, :load)
  def load(port, proc = nil)
    th_core_load(port, proc)  # usual loading
  rescue TypeError
    if port.kind_of?(File)    # didn't work, so we read it as a raw file
      port.rewind 
      port.read
    else
      port
    end
  end
  
  
  def exists(port, proc = nil)
  th_core_load(port, proc)  # usual loading
  rescue TypeError
    if port.kind_of?(File)    # didn't work, so we read it as a raw file
      port.rewind 
      port.read
    else
      port
    end
  end
end unless Marshal.respond_to?(:th_core_load)