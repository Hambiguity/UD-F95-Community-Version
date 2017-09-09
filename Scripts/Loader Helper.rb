class LoaderHelper
    def self.run_loader_helper 
      
        #Removing Crappy Phone
        crappy_phone_1 = $data_items[1]
        crappy_phone_2 = $data_items[11]
        
        if $game_party.has_item?(crappy_phone_1, false) then
          $game_party.lose_item(crappy_phone_1, 1)
          $game_party.gain_gold(25)
        end
        
        if $game_party.has_item?(crappy_phone_2, false) then
          $game_party.lose_item(crappy_phone_2, 1)
          $game_party.gain_gold(25)
        end
        
        #Kimberly Purty/Corruption Correct Lock in
        if $game_variables[842] > 0 then
          $game_switches[810] = true
        end
        
        if $game_variables [843] > 0 then
          $game_switches[811] = true
        end
        
        if $game_switches[133] == true then
          $game_switches[134] = true
        end
    end
end