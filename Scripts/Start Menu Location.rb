class Window_TitleCommand < Window_Command
  def update_placement
    half_screen_x = Graphics.width/2
    half_width = self.width/2
    
    self.x = half_screen_x - half_width
    
    twenty_percent_height = Graphics.height/5
    y_pos = twenty_percent_height * 4
    
    self.y = y_pos
  end
end