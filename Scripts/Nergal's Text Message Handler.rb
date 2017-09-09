module Text_Handler_Config

# 'Text Name' => Switch number.

TEXT_MESSAGES = [
['MomTestMessage', 142],
['MrsJSickReply', 143],
['MrsJParkReply', 144],
['MrsJParkReply2', 145],
['DonnaTextReminder', 146],
['MrsJParkReplyNotThere',147],
['MrsJParkReply3',148],
['SydneyShowerReply1',149],
['SydneyShowerReply2g',150],
['SydneyShowerReply2c',151],
['KimberlyReply',152],
['SarahSendsRecording', 153],
['SarahSendsRecordingReply', 154],
['SarahPureParkReply', 155],
['BabysittingReplyDizzy', 156],
['MrsJenningsPureToiletMeet', 157],
['MrsJBabysittingReplyNo',158],
['MrsJBabysittingReplyYesC',159],
['MrsJBabysittingReplyYesP',160],
['KimberlyBabysittingReplyNo',161],
['KimberlyBabysittingReplyYesP',162],
['KimberlyBabysittingReplyYesC',163],
['NealaBabysittingReplyNo',164],
['NealaBabysittingReplyYesP',165],
['NealaBabysittingReplyYesC',166],
['SarahBSReplyNo',167],
['SarahBSReplyYesP',168],
['SarahBSReplyYesP',169],
['LisaBSReplyNo',170],
['LisaBSReplyYesP',171],
['LisaBSReplyYesC',172],
['MsAmosBsReplyNo',173],
['MsAmosBsReplyYesP',174],
['MsAmosBsReplyYesC',175],
['MrsJenningsInvite',176],
]

FOLDER_LOC = "Data/Text Messages/"
TEXT_CHOICES_LOC = FOLDER_LOC + "Text Choices/"

TEXT_DELAY_COUNT = 20

DELAY_COUNT_VAR = 17
TEXT_TO_SEND_VAR = 18

TEXT_ORDER_VAR = 19

end

include Text_Handler_Config

class Text_Handler
  def self.prepare_text_send(switch)
    $game_variables[DELAY_COUNT_VAR] = TEXT_DELAY_COUNT
    $game_variables[TEXT_TO_SEND_VAR] = switch
  end
  
  def self.send_immediate_text(switch)
    $game_variables[TEXT_TO_SEND_VAR] = switch
    send_text
  end
  
  
  def self.send_text
    
    $game_switches[$game_variables[TEXT_TO_SEND_VAR]] = true
    Audio.se_play("Audio/SE/computer_instant_message_alert_02", 100, 100)
    CustomGab.display_message("New Message Received")
    
    if $game_variables[TEXT_ORDER_VAR] == 0 then
      $game_variables[TEXT_ORDER_VAR] = []
    end
    
    $game_variables[TEXT_ORDER_VAR] = $game_variables[TEXT_ORDER_VAR].unshift $game_variables[TEXT_TO_SEND_VAR]
  end
      
  def self.get_text(name)    
    begin
      file = load_data(FOLDER_LOC + name + ".txt")
    rescue 
      return ["NULL", "NULL"]
    end
    
    split = file.split("\n")
    
    message = split[1]
    if name_replacements = message.scan(/(N<(\d+)>)/) then
      name_replacements.each do | replacement |
        message = message.gsub(replacement[0],$game_actors[replacement[1].to_i].name)
      end
    end
    
    return [$game_actors[split[0].to_i].name,message]
  end
  
  def self.get_all_available_texts
    return_list = []
    
    if $game_variables[TEXT_ORDER_VAR] == 0 then
      return return_list
    end   
    
    current_texts = $game_variables[TEXT_ORDER_VAR]
    max = current_texts.count - 1
    
    for i in 0..max 
      puts $game_switches[current_texts[i]]
      if $game_switches[current_texts[i]] == true then
        text_msg = TEXT_MESSAGES.find{|x| x[1] == current_texts[i]}

        text = get_text(text_msg[0])
        return_list.push text
      end
    end
    
    return return_list   
  end
  
  
  def self.get_player_send_text_options(actor_id)
   
    begin    
      file = load_data(TEXT_CHOICES_LOC + actor_id.to_s + ".txt")        
    rescue 
      puts "failed to load: " + actor_id.to_s + ".txt"
      return
    end
    
    choices = []
    
    #EVALUATION|DISPLAY VALUE|TEXT VALUE|REPLY TEXT|SWITCH TO SET
    if match = file.scan(/<choice:(.+)\|(.+)\|(.+)\|(\d+)\|(\d+)>/) then     
      match.each do | cur_match |
        evaluation = cur_match[0]
        display_name = cur_match[1]
        text_value = cur_match[2]
        reply_text = cur_match[3]
        switches_to_flag = cur_match[4]
        
        puts evaluation

        result = eval(evaluation)
        
        if result == false then
          next
        end
        
        if name_replacements = text_value.scan(/(N<(\d+)>)/) then
          name_replacements.each do | replacement |
            text_value = text_value.gsub(replacement[0],$game_actors[replacement[1].to_i].name)
          end
        end
        
        
        choices.push [display_name,text_value, switches_to_flag.to_i]
                
        reply = reply_text.to_i
        if reply > 0 then
          prepare_text_send(reply)
        end
        
      end
    end
    
    return choices

  end
  
end

class Game_Interpreter
  def prepare_text_send(switch)
    Text_Handler.prepare_text_send(switch)
  end
  
  def send_immediate_text(switch)
    Text_Handler.send_immediate_text(switch)
  end
end

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    super
    if normal_walk? then
      $game_party.increase_steps
      #If we are delaying a text
      if $game_variables[DELAY_COUNT_VAR] > 0 then
        $game_variables[DELAY_COUNT_VAR] = $game_variables[DELAY_COUNT_VAR] - 1
        #Check to see if text is ready to be sent
        if $game_variables[DELAY_COUNT_VAR] == 0 then
          Text_Handler.send_text
        end
      end
    end
  end
end















