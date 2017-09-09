class Game_Interpreter
  def reset_self_switches
      switches = ["A","B","C","D"]
    
      map_id = $game_map.map_id
      $game_map.events.each do |i, event|
        for switch in switches
          puts map_id.to_s + " " + i.to_s + " " + switch
          key = [map_id, i, switch]
          $game_self_switches[key] = false   
        end  
      end    
    end
    
  def reset_map
    $game_map.setup(@map_id)
  end
  
end