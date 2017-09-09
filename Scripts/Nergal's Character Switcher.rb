module CharSwitcher_Config

end
include CharSwitcher_Config

class Char_Switcher
  
  
  
end


class Game_System
  attr_accessor :char_name
  attr_accessor :char_gold
  attr_accessor :char_item_id
  attr_accessor :char_item_qty
  
  alias char_initialize initialize
  def initialize
    char_initialize
    @char_name = []
    @char_gold = []
    @char_item_id = []
    @char_item_qty = []
  end 
  
end

class Game_Interpreter
  def change_char(old_char,new_char)
    add_new_records_if_needed(old_char)
    add_new_records_if_needed(new_char)
    
    store_old_gold(old_char)
    store_old_items(old_char)
    
    set_new_gold(new_char)
    set_new_items(new_char)
    
  end
  
  def add_new_records_if_needed(char)
      exists = does_record_exist?(char)
      
      if exists == true then
        return
      end
      
      add_new_record(char)    
  end
    
  def does_record_exist?(char)
    for i in 0...$game_system.char_name.size
      if $game_system.char_name[i] == char
        return true
      end
    end
    return false
  end
  
  def add_new_record(char)
    puts "Added new record for " + char
    $game_system.char_name.push char
    $game_system.char_gold.push 0
    $game_system.char_item_id.push []
    $game_system.char_item_qty.push []
  end
  
  def store_old_gold(char)
    index = $game_system.char_name.index(char)
    $game_system.char_gold[index] = $game_party.gold  
    puts "Stored old gold " + $game_party.gold.to_s
  end
  
  def store_old_items(char)
    index = $game_system.char_name.index(char)
    
    arr_items = []
    arr_qty = []
    
    $game_party.items.each do | item |
      qty = $game_party.item_number(item)    
      puts "(" + char + ") Stored: " + item.name + " - " + qty.to_s
      arr_items.push item
      arr_qty.push qty
    end
    
    $game_system.char_item_id[index] = arr_items
    $game_system.char_item_qty[index] = arr_qty
    
  end
  
  def set_new_gold(char)
    gold_val = $game_system.char_gold[$game_system.char_name.index(char)]
    $game_party.lose_gold($game_party.gold)
    $game_party.gain_gold(gold_val)
  end
  
  def set_new_items(char)
    puts "Attempting retrieval with: " + char
    $game_party.init_all_items
    
    index = $game_system.char_name.index(char)
    
    items = $game_system.char_item_id[index]
    qtys = $game_system.char_item_qty[index]
     
    if items.count <= 0 then
      return
    end
    
    count = items.count - 1
    
    for i in 0..count
      puts "(" + char + ") Retrieved: " + items[i].name + " - " + qtys[i].to_s
      $game_party.gain_item(items[i], qtys[i])
    end
   
  end
end
