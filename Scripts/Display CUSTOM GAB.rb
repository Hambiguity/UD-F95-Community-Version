class CustomGab
  
  #Stores the message to display in the GAB window
  MESSAGE_VAR = 15
  #Common Event that displays text stored in VAR above
  DISPLAY_MESSAGE_COMMON_EVENT = 66
  
  ## Show Message ##
  def self.display_message(message)
    $game_variables[MESSAGE_VAR] = message
    $game_temp.reserve_common_event(DISPLAY_MESSAGE_COMMON_EVENT)
  end
end



class Game_Interpreter
    def display_message(message)
      CustomGab.display_message(message)
    end
end