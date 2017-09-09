class FeedbackMsg
  def self.display_feedback(message)    
      max_x = Graphics.width / 2
      max_y = Graphics.height / 2
      width = Graphics.width / 2
      height = Graphics.height / 2
             
      @win_feedback = Window_Base.new(max_x, max_y, width, height)
      @win_feedback.opacity = 0
      @win_feedback.z = 15
      
      Audio.se_play("Audio/SE/Buzzer1", 80, 100)
      
      @win_feedback.contents.font.size = 40
      text_width = @win_feedback.contents.text_size(message).width
      text_height = @win_feedback.contents.text_size(message).height
      
      @win_feedback.width = text_width + 40
      @win_feedback.height = text_height * 2
      @win_feedback.x = max_x - (@win_feedback.width / 2)
      @win_feedback.y = max_y - (@win_feedback.height / 2)

      @win_feedback.draw_text(0, 0, text_width+400, text_height, message)
      
      fade_out = 60
      i = fade_out
    
      while i > 0 do
        @win_feedback.opacity = @win_feedback.contents_opacity =  i * (256/fade_out)
        @win_feedback.update
        Graphics.update
        i = i - 1
      end
      
      @win_feedback.dispose
  end
end