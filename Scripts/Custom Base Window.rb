class Window_Base < Window
  # "true" to enable override, "false" to use default 
  USE_WINDOWSKIN = true 
  
  # Update Tone 
  def update_tone 
    self.tone.set($game_system.window_tone) unless USE_WINDOWSKIN 
  end 
end