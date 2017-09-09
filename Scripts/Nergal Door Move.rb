class DoorMove
  DOOR_EVENT_ID_VAR = 147
  
  def self.open_door
    
    mr = RPG::MoveRoute.new
    mr.repeat = false
    mr.wait = true
    mr.list = []
    
    mr.list.push( RPG::MoveCommand.new(17, []) )
    mr.list.push( RPG::MoveCommand.new(15, [3]) )
    mr.list.push( RPG::MoveCommand.new(18, []) )
    mr.list.push( RPG::MoveCommand.new(15, [3]) )
    mr.list.push( RPG::MoveCommand.new(19, []) )
    
    $game_map.events[$game_variables[147]].force_move_route(mr)
  end
  
  def self.close_door
    
    mr = RPG::MoveRoute.new
    mr.repeat = false
    mr.wait = true
    mr.list = []

    mr.list.push( RPG::MoveCommand.new(18, []) )
    mr.list.push( RPG::MoveCommand.new(15, [3]) )
    mr.list.push( RPG::MoveCommand.new(17, []) )
    mr.list.push( RPG::MoveCommand.new(15, [3]) )
    mr.list.push( RPG::MoveCommand.new(16, []) )

    $game_map.events[$game_variables[147]].force_move_route(mr)
  end
  
  
  
end
