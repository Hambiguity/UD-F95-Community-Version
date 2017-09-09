module Journal_Handler_Config


FOLDER_LOC = "Data/Journal/"
COMMANDS_NAME = "JournalCommands"

end

class Journal_Handler


  def self.get_all_available_entries
    return_list = []
    
    begin
      file = load_data(Journal_Handler_Config::FOLDER_LOC + Journal_Handler_Config::COMMANDS_NAME + ".txt")
    rescue 
      return ["NULL", "NULL"]
    end
    
    #EVALUATION|DISPLAY VALUE|TEXT VALUE|REPLY TEXT|SWITCH TO SET
    if match = file.scan(/<entry:(.+)\|(.+)\|(.+)\>/) then     
      match.each do | cur_match |
        evaluation = cur_match[0]
        display_name = cur_match[1]
        file_name = cur_match[2]

        result = eval(evaluation)
        
        puts evaluation
        
        if result == false then
          next
        end
        
        text_value = get_entry(file_name)
        
        text = FreeText_Handler.convert_escape_characters(text_value)

        return_list.push [display_name,text]

      end
    end
    puts "returning list"
    
    return return_list   
  end
  
  def self.get_entry(file_name)
    begin
      file = load_data(Journal_Handler_Config::FOLDER_LOC + file_name + ".txt")
    rescue 
      return "ERROR LOADING: " + file_name + ".txt"
    end
    
    return file
    
  end
  
end