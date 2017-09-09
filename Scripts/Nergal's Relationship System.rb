
module NergRel
# ------------------------------------------------------------------------------
# *Customization
# ------------------------------------------------------------------------------
  # Change the title of the scene
  TITLE = "Rel. Change"
  
  # While this switch is OFF the text pop-up will show when you change reputation
  # or add a new char/faction to the list
  POPUP_SWITCH = 2
  
  # Determine the speed of the text pop-up (0-slowest, 4-fastest)
  POPUP_SPEED = 2
  
  # Set this to true if you want the text window to pop up (otherwise it will be
  # static)
  POPUP = false
  
  # Set this to false if you don't want a sound to play on pop-up
  PLAY_SOUND = true
  # Sound to play upon pop-up
  COR_S_NAME  = 'Audio/SE/Darkness1'
  S_NAME   = 'Audio/SE/Chime2'
  S_VOLUME = 80
  S_PITCH  = 150
  
  # Set this to true if you want a button press to terminate the window
  BUTTON_WAIT = false
  # Which buttons should be pressed to terminate the pop-up window
  BUTTON_1 = Input::C
  BUTTON_2 = Input::B
  
  # Frames to wait to terminate the pop-up window automatically (if the above is
  # false)
  TIME = 45
  
  CURRENT_ACTOR_ID_VAR = 20
  
  MAX_CORRUPTUION = 100
  MAX_RELATIONSHIP = 100
  
  
  RELATIONSHIP_LOCK_LEVEL = [0,20,40,60,80,100]
# ------------------------------------------------------------------------------
# *End Customization
# ------------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# - reputation data dump
#-------------------------------------------------------------------------------
class Game_System
  attr_accessor :rep_id
  attr_accessor :rep_val #"Kindness" level
  attr_accessor :cor_lvl #"Corruption" level
  attr_accessor :sex_lvl # - this level determines what dialogue should display
  
  alias rep_initialize initialize
  def initialize
    rep_initialize
    @rep_id = []
    @rep_val = []
    @cor_lvl = []
    @sex_lvl = []
  end
end

#-------------------------------------------------------------------------------
# - control methods
#-------------------------------------------------------------------------------
class Game_Interpreter
  #$scene1 = Scene_Menu.new(0)
  
  ###Create Methods
  
  def add_rep(id, name, silent_add = false)
    Rel_System.add_rep(id, name, silent_add )
  end
  
  ###End of Create Methods
  
  ###Read Methods
  
  def return_rep(name)
    return Rel_System.return_rep(name)
  end
  
  def return_corruption(name)
    return Rel_System.return_corruption(name)  
  end
  
  def return_current_char_corruption
    return Rel_System.return_current_char_corruption
  end
  
  def return_total_corruption
    return Rel_System.return_total_corruption
  end
  
  def return_sex_level(name)
    return Rel_System.return_sex_level(name)
  end
  
  def is_pur_more_than_cor?(name)
    return Rel_System.is_pur_more_than_cor?(name)
  end
  
  def is_cor_more_than_pur?(name)
    return Rel_System.is_cor_more_than_pur?(name)
  end
  
  ###End of Read Methods
   
  ###Update Methods
  
  def change_rep(name, value,silent_add = false)
    return Rel_System.change_rep(name, value, silent_add)
  end
    
  def gain_corruption(name, value,silent_add = false)
    return Rel_System.gain_corruption(name, value, silent_add)
  end
  
  def debug_set(name)
    return Rel_System.debug_set(name)
  end
  
  ###End of Update Methods
  
  ####################################KinnermanModMethods###############################
   def set_rep(name, value)
    return Rel_System.set_rep(name, value)
  end
  
  def set_corruption(name, value)
    return Rel_System.set_corruption(name, value)
  end

  def find_rep(name)
    return Rel_System.find_rep(name)
  end
  
  def find_corruption(name)
    return Rel_System.find_corruption(name)
  end
  
####################################KinnermanModMethods###########################

  ###Misc Methods
  
  #Need ID instead of name, because of multiple main characters
  def return_id(name)
    return Rel_System.return_id(name)
  end
  
  def rep_defined?(id)
    return Rel_System.rep_defined?(id)
  end
  
  ###End of Misc Methods

end

#-------------------------------------------------------------------------------
# - control methods
#-------------------------------------------------------------------------------
class Rel_System
  $scene1 = Scene_Menu.new(0)
  
  ###Create Methods
  
  def self.add_rep(id, name, silent_add = false)
    $game_system.rep_id.push id
    $game_system.rep_val.push 0
    $game_system.cor_lvl.push 0
    $game_system.sex_lvl.push 0
    if silent_add == false then
      $scene1.item_popup(name,0) unless $game_switches[NergRel::POPUP_SWITCH]
    end
  end
  
  ###End of Create Methods
  
  ###Read Methods
  
  def self.return_rep(name)
    id = return_id(name)
    
    return $game_system.rep_val[$game_system.rep_id.index(id)]
  end
  
  def self.return_corruption(name)
    id = return_id(name)
    return $game_system.cor_lvl[$game_system.rep_id.index(id)]    
  end
  
  def self.return_current_char_corruption
    
    actor_id = $game_variables[NergRel::CURRENT_ACTOR_ID_VAR]
    
    id = return_id($game_actors[actor_id].name)
    
    cor_count = 0
    
    for i in 0...$game_system.rep_id.size
      if $game_system.cor_lvl[i] > 0
        puts $game_system.rep_id[i]
        puts "-"+id.to_s
        if $game_system.rep_id[i].end_with? "-"+actor_id.to_s then
          cor_count += $game_system.cor_lvl[i]
        end
      end
    end
    return cor_count
  end
  
  def self.return_total_corruption
    cor_count = 0
    for i in 0...$game_system.rep_id.size
      if $game_system.cor_lvl[i] > 0
        cor_count += $game_system.cor_lvl[i]
      end
    end
    return cor_count
  end
  
  def self.return_sex_level(name)
    id = return_id(name)
    return $game_system.sex_lvl[$game_system.rep_id.index(id)]  
  end
  
  def self.return_current_char_romances_count
    count = 0
    str_to_match = "-" + $game_variables[NergRel::CURRENT_ACTOR_ID_VAR].to_s
    puts str_to_match
    for i in 0...$game_system.rep_id.size 
      puts $game_system.rep_id[i]
      if $game_system.rep_id[i].end_with?(str_to_match) then
        count = count + 1
      end
    end
    
    return count
  end
  
  def self.return_current_char_romance_ids
    actor_names = []
    str_to_match = "-" + $game_variables[NergRel::CURRENT_ACTOR_ID_VAR].to_s
    puts str_to_match
    for i in 0...$game_system.rep_id.size 
      if $game_system.rep_id[i].end_with?(str_to_match) then
        actor_names.push $game_system.rep_id[i].chomp(str_to_match)
      end
    end

    ids = []

    for i in 1..$data_actors.count - 1
      actor = $game_actors[i]
      actor_names.each do | name |
        if actor.name == name then
          ids.push actor.id
          puts actor.id
        end
      end
    end
    
    return ids
  end
  
  def self.is_pur_more_than_cor?(name)
    id = return_id(name)
    
    if rep_defined?(id) == false then
      return true
    end    
    
    pur = return_rep(name)
    cor = return_corruption(name)
    
    if pur >= cor then
      return true
    end
    
    return false    
  end
  
  def self.is_cor_more_than_pur?(name)
    id = return_id(name)
    
    if rep_defined?(id) == false then
      return false
    end 
    
    pur = return_rep(name)
    cor = return_corruption(name)
    
    if cor >= pur then
      return true
    end
    
    return false    
  end
  
  ###End of Read Methods
   
  ###Update Methods
  
  def self.change_rep(name, value, silent_add)
    id = return_id(name)
    
    if rep_defined?(id) == false
      add_rep(id,name, silent_add)
    end
    
    index = $game_system.rep_id.index(id)
    
    if $game_system.rep_val[index] == NergRel::MAX_RELATIONSHIP then
      return
    end
    
    $game_system.rep_val[index] += value
    
    if $game_system.rep_val[index] > NergRel::MAX_RELATIONSHIP then
      $game_system.rep_val[index] = NergRel::MAX_RELATIONSHIP
    end
    
    recalculate_sex_level(index)
    
    if silent_add == true then
      puts "SILENT ADDED REP FOR CHARACTER: " + name + ". Amount: " + value.to_s
      return
    end

    $scene1.item_popup(name,value) unless $game_switches[NergRel::POPUP_SWITCH]
  end
  
###########################################################################  
#########################KinnermanModStart#################################
###########################################################################
  def self.set_rep(name, value)
    id = return_id(name)
    
    if rep_defined?(id) == false
      add_rep(id,name)
    end
    
    index = $game_system.rep_id.index(id)
    
    $game_system.rep_val[index] = value
    
    if $game_system.rep_val[index] > NergRel::MAX_RELATIONSHIP then
      $game_system.rep_val[index] = NergRel::MAX_RELATIONSHIP
    end
    
    recalculate_sex_level(index)

  end
  
  def self.set_corruption(name, value)
    id = return_id(name)
    
    #We don't want to gain corruption for a char that doesn't exist
    if rep_defined?(id) == false
      return
    end
    
    index = $game_system.rep_id.index(id)
    
    $game_system.cor_lvl[index] = value
    
    if $game_system.cor_lvl[index] > NergRel::MAX_CORRUPTUION then
      $game_system.cor_lvl[index] = NergRel::MAX_CORRUPTUION
    end
        
    recalculate_sex_level(index)

  end

  def self.find_rep(name)
    id = return_id(name)
    rel_level = Rel_System.return_rep(name)
    $game_variables[175] = rel_level
  end  

  def self.find_corruption(name)
    id = return_id(name)
    cor_level = Rel_System.return_corruption(name)
    $game_variables[176] = cor_level
  end
###########################################################################  
#########################KinnermanModEnd###################################
###########################################################################

  def self.gain_corruption(name, value, silent_add)
    id = return_id(name)
    
    #We don't want to gain corruption for a char that doesn't exist
    if rep_defined?(id) == false
      add_rep(id,name,silent_add)
    end
    
    index = $game_system.rep_id.index(id)
    
    if $game_system.cor_lvl[index] == NergRel::MAX_CORRUPTUION then
      return
    end
    
    $game_system.cor_lvl[index] += value
    
    if $game_system.cor_lvl[index] > NergRel::MAX_CORRUPTUION then
      $game_system.cor_lvl[index] = NergRel::MAX_CORRUPTUION
    end
        
    recalculate_sex_level(index)
    
    if silent_add == true then
      puts "SILENT ADDED COR FOR CHARACTER: " + name + ". Amount: " + value.to_s
      return
    end
        
    $scene1.item_popup(name, value, 1) unless $game_switches[NergRel::POPUP_SWITCH]      
  end
  
  def self.recalculate_sex_level(index)
    rel = $game_system.rep_val[index]
    corr = $game_system.cor_lvl[index]
    
    values = rel + corr
    
    sex_lvl = (values / 20).round
    
    if sex_lvl < 0 then
      sex_lvl = 0
    end
    
    $game_system.sex_lvl[index] = sex_lvl
  end
  
  def self.debug_set(name)
    id = return_id(name)
    
    if rep_defined?(id) == false
      add_rep(id,name,true)
    end
    
    index = $game_system.rep_id.index(id)
    
    $game_system.rep_val[index] = 100

    $game_system.cor_lvl[index] = 100
        
    recalculate_sex_level(index)
  end
  
  ###End of Update Methods
  
 
  ###Misc Methods
  
  #Need ID instead of name, because of multiple main characters
  def self.return_id(name)
    return name + "-" + $game_variables[NergRel::CURRENT_ACTOR_ID_VAR].to_s
  end
  
  def self.rep_defined?(id)
    for i in 0...$game_system.rep_id.size
      if $game_system.rep_id[i] == id
        return true
      end
    end
    return false
  end
  
  def self.has_any_reps?
    id_to_match = "-" + $game_variables[NergRel::CURRENT_ACTOR_ID_VAR].to_s
    for i in 0...$game_system.rep_id.size
      if $game_system.rep_id[i].include? id_to_match
        return true
      end
    end
    return false
  end
  
  ###End of Misc Methods

end

    
#-------------------------------------------------------------------------------
# - window setting
#-------------------------------------------------------------------------------

class Window_Help < Window_Base
  
  def set_text_rep(text)
    if text != @text
      @text = text
    end
    contents.clear
    draw_text(0,0,Graphics.width,24,@text, 1)
  end
end
    

class Window_Reputation < Window_Selectable
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 1
    self.index = 0
    @data = $game_system.rep_name
    refresh
  end
  
  def refresh
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  def draw_rep_name(name, x, y)
    if name != nil
      self.contents.font.color = normal_color
      self.contents.draw_text(x+10, y, 172, line_height, name)
    end
  end
  
  def sign(num)
    if num > 0
      self.contents.font.color.set(0,255,0)
      sign = "+%d"
    elsif num < 0
      self.contents.font.color.set(255,0,0)
      sign = "%d"
    elsif num == 0
      sign = "%d"
    end
    return sign
  end
  
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_system.rep_val[index]
      rect.width -= 4
      draw_rep_name(@data[index], rect.x, rect.y)
      self.contents.draw_text(rect, sprintf(sign(number), number), 2)
      self.contents.font.color = normal_color
    end
  end  
end
#-------------------------------------------------------------------------------
# - popup window by OriginalWij
#-------------------------------------------------------------------------------
class Scene_Base
  def item_popup(text, amount, type = 0, del=false)
    
    width = Graphics.width
    height = Graphics.height
    
    max_x = Graphics.width / 2
    max_y = Graphics.height / 2
    
    z = 2000
    
    fade_in_time = 0.5 * 60
    pause_time = 1 * 60
    fade_out_time = 0.75 * 60
       
    @popup_window = Window_Base.new(max_x, max_y, width, height)
    @popup_window.opacity = @popup_window.contents_opacity = 0
    
    @popup_window.z = z
       
    if NergRel::PLAY_SOUND
      Audio.se_play(NergRel::S_NAME, NergRel::S_VOLUME, NergRel::S_PITCH)
    end
    
    output = ""
    if type == 0 then #rel gain
      if amount > 0 
        @popup_window.contents.font.color.set(0,255,0) #green
        output = text + " +" + amount.to_s
      elsif amount < 0 
        @popup_window.contents.font.color.set(255,46,0) #red
        output = text + " " + amount.to_s
      elsif amount == 0
        @popup_window.contents.font.color.set(255,255,0) #yellow
        output = "NEW! - " + text
      end
    else #corruption gain
      @popup_window.contents.font.color.set(255,46,0) #red
      output = text + " +" + amount.to_s + " CORRUPTION!"
    end

    @popup_window.contents.font.size = 40
    text_width = @popup_window.contents.text_size(output).width
    text_height = @popup_window.contents.text_size(output).height
    
    @popup_window.width = text_width + 40
    @popup_window.height = text_height * 2
    @popup_window.x = max_x - (@popup_window.width / 2)
    @popup_window.y = max_y - (@popup_window.height / 2)
    
    puts output
    @popup_window.draw_text(0, 0, text_width+400, text_height, output)
    
    for i in 1..fade_in_time
      @popup_window.opacity = @popup_window.contents_opacity =  i * (256/fade_in_time)
      @popup_window.update
      Graphics.update
    end
    
    for i in 1..pause_time
      Graphics.update
      Input.update
    end
    
    i = fade_out_time
    
    while i > 0 do
      @popup_window.opacity = @popup_window.contents_opacity =  i * (256/fade_in_time)
      @popup_window.update
      Graphics.update
      i = i - 1
    end
    
    @popup_window.dispose
  end
  
  def cor_popup(val, del=false)
    x = $game_player.screen_x - 26
    y = $game_player.screen_y - 48
    @cor_popup_window = Window_Base.new(x, y, 56, 56)
    @cor_popup_window.opacity = @cor_popup_window.contents_opacity = 0

    max = NergRel::POPUP_SPEED * 4 + 16
    for i in 1..max
      @cor_popup_window.contents_opacity = i * (256 / max)
      @cor_popup_window.y -= (32 / max)
      @cor_popup_window.update
      Graphics.update
    end
          
    if NergRel::PLAY_SOUND
      Audio.se_play(NergRel::COR_S_NAME, NergRel::S_VOLUME, NergRel::S_PITCH)
    end

    
    am_str = "Corruption: +" + val.to_s 
    
    a_width = @cor_popup_window.contents.text_size(am_str).width
    x = (Graphics.width - (a_width + 64))
    y = 32
    y += 32 if NergRel::POPUP
    @cor_name_window = Window_Base.new(x, y, a_width + 32, 56)
    @cor_name_window.opacity = @cor_name_window.contents_opacity = 0
    w = a_width

    @cor_name_window.contents.font.color.set(240,0,0)
    
    @cor_name_window.contents.draw_text(0, 0, w+32, 24, am_str)
    for i in 1..max
      @cor_name_window.y -= (32 / max) if NergRel::POPUP
      @cor_name_window.contents_opacity = i * (256 / max)
      @cor_name_window.opacity = i * (256 / max)
      @cor_name_window.update
      Graphics.update
    end
    count = 0
    loop do
      break
      Graphics.update
      Input.update
      count += 1 unless NergRel::BUTTON_WAIT
      break if Input.trigger?(NergRel::BUTTON_1) and NergRel::BUTTON_WAIT
      break if Input.trigger?(NergRel::BUTTON_2) and NergRel::BUTTON_WAIT
      break if count == NergRel::TIME and NergRel::BUTTON_WAIT
    end
    for i in 1..max
      @cor_popup_window.contents_opacity = 256 - i * (256 / max)
      @cor_name_window.opacity = 256 - i * (256 / max)
      @cor_name_window.contents_opacity = 256 - i * (256 / max)
      @cor_popup_window.update
      @cor_name_window.update
      Graphics.update
    end
    @cor_popup_window.dispose
    @cor_name_window.dispose
    Input.update
  end
end

#-------------------------------------------------------------------------------
# - reputation scene processing
#-------------------------------------------------------------------------------
class Scene_Rep < Scene_Base
  def start
    super
    create_main_viewport
    
    @viewport = Viewport.new(0, 0, 640, 480)
    @help_window = Window_Help.new(1)
    @help_window.viewport = @viewport
    x = (Graphics.width/2)-165
    @rep_window = Window_Reputation.new(x, 56,350, 360)
    @rep_window.viewport = @viewport
    @rep_window.help_window = @help_window
    @rep_window.active = true
    @help_window.set_text_rep(NergRel::TITLE)
  end
  
  def terminate
    super
    @help_window.dispose
    @rep_window.dispose
    @viewport.dispose
  end
  
  def return_scene
    SceneManager.return
  end
  
  def update
    super
    update_all_windows
    @help_window.update
    @rep_window.update
    if @rep_window.active
      update_rep_selection
    end
  end
  
  def update_rep_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
  
end 