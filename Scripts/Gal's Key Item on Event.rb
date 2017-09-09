#------------------------------------------------------------------------------#
#  Galv's Use Item on Event
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.5
#------------------------------------------------------------------------------#
#  2013-01-10 - version 1.5 - added a hopeful fix for strange issue
#  2012-12-13 - version 1.4 - added ability to set what happens when item is 
#                             used on nothing (or an event with no <key> tag).
#                           - added a check for just category
#  2012-12-07 - version 1.3 - bug where sometimes item doesn't register
#  2012-12-07 - version 1.2 - fix indexing bug when changing categories
#  2012-12-07 - version 1.1 - fixed bug when only using 1 category
#  2012-12-07 - version 1.0 - release
#------------------------------------------------------------------------------#
#  This script allows you to bring up the "Use Key Item" box on the press of a
#  button. When you select an item, it then activates the event directly in
#  front of the player.
#  Using EVENTING knowledge, you can set up conditional branches that contain
#  'script' condition to tell the event what to do when the item the player
#  selected was used on that event.
#------------------------------------------------------------------------------#
#  SCRIPTS for CONDITIONAL BRANCHES
#------------------------------------------------------------------------------#
#
#  use_key?            # Returns true if you activated the event using an item.
#
#  key?(:category,item_id)    # Checks if that item was used.
#                             # :category can be any from CATEGORIES below.
#                             # item_id is the ID of the item from that category
#
#  keyc?(:category)           # Check if any item from that category was used
#
#------------------------------------------------------------------------------#
#  SCRIPT call for ENDING an item-initiated event (IMPORTANT)
#------------------------------------------------------------------------------#
#
#  end_key      # Use this instead of "Exit Event Processing" event command in
#               # your item activated events to clear the item ID if you want
#               # to end the event early like in the demo examples.
#
#------------------------------------------------------------------------------#
#  COMMENT TAG FOR EVENTS
#------------------------------------------------------------------------------#
#
#  <key>
#
#  Place a COMMENT in the event page with only this tag in it. Make sure the
#  comment is BELOW all conditional branches checking for item used on the event
#
#  Any event that has this comment will be activated when using an item on it
#  (just like if you used the action key). Any event without this tag will not
#  be activated at all and will revert to the common event id (selected below).
#
#------------------------------------------------------------------------------#
 
($imported ||= {})["Galvs_Use_Item_on_Event"] = true
module Galv_Key
   
#------------------------------------------------------------------------------#
#  SCRIPT SETTINGS
#------------------------------------------------------------------------------#  
 
  DISABLE_SWITCH = 5
   
  BUTTON = :X       # Button to call Key Item window (:X is "a")
   
  VARIABLE = 10      # Stores item ID in this variable to use in conditions
   
  NO_TARGET = 58   # Common event ID. This is called when the player uses an
                    # item on nothing and can be used to set what happens for
                    # each item/category in this event.
                    # IMPORTANT: Set to 0 if not used. Common event MUST have
                    # the key_end script call at the end of the event and end
                    # of any branch as normal.
   
  CATEGORIES = [                 # Categories of items that can be used on an
                                 # event. Cycle through these categories with
    [:key_item, "Key Items"],    # Q and W. Remove any you do not want to use
    [:item, "Items"],            # in your game.
    #[:weapon, "Weapons"],
    #[:armor, "Armor"],
     
    ] # don't touch
     
  CHANGE_CAT_LEFT = "S <  "      # Text before the heading
  LEFT_BUTTON = :Y               # Button to swap category to the left
  CHANGE_CAT_RIGHT = "  > D"     # Text after the heading
  RIGHT_BUTTON = :Z              # Button to swap category to the right
     
     
#------------------------------------------------------------------------------#
#  END SCRIPT SETTINGS
#------------------------------------------------------------------------------#  
 
end
 
 
class Game_Interpreter
 
  alias galv_key_item_interpreter_execute_command execute_command
  def execute_command
    if !@list[@index].nil?
      if @list[@index].code == 108
        $game_variables[Galv_Key::VARIABLE] = 0 if @list[@index].parameters[0] == "<key>"
      end
    end
    galv_key_item_interpreter_execute_command
  end
   
  def end_key
    @index = @list.size
    $game_variables[Galv_Key::VARIABLE] = 0
  end
 
  def use_key?
    $game_variables[Galv_Key::VARIABLE] > 0
  end
   
  def key?(item_id)
    if $game_variables[Galv_Key::VARIABLE] == item_id
      return true
    else
      return false
    end
  end
   
  
  def key?(cat,item_id)
    if cat == $game_system.key_item_cat && $game_variables[Galv_Key::VARIABLE] == item_id
      return true
    else
      return false
    end
  end
   
  def keyc?(cat)
    if cat == $game_system.key_item_cat && $game_variables[Galv_Key::VARIABLE] > 0
      return true
    else
      return false
    end
  end
  
end # Game_Interpreter
 
 
class Game_Player < Game_Character
 
  alias galv_key_item_move_by_input move_by_input
  def move_by_input
    galv_key_item_move_by_input
    if Input.trigger?(Galv_Key::BUTTON)
      return if $game_switches[Galv_Key::DISABLE_SWITCH] || jumping?
      $game_message.item_choice_variable_id = Galv_Key::VARIABLE if !$game_map.interpreter.running?      
    end
  end
   
  def use_on_event
    case @direction
    when 2; dirx = 0; diry = 1
    when 4; dirx = -1; diry = 0
    when 6; dirx = 1; diry = 0
    when 8; dirx = 0; diry = -1
    end
     
    @enable_event = false
    for event in $game_map.events_xy(@x+dirx, @y+diry)
      if event == nil || event.list == nil then
        next
      end
      event.list.count.times { |i|
        if event.list[i].code == 108 && event.list[i].parameters[0] == "<key>"
          @enable_event = true
        end
      }
    end
     
    if @enable_event
      event.start
    else
      if Galv_Key::NO_TARGET > 0
        $game_temp.reserve_common_event(Galv_Key::NO_TARGET)
      else
        $game_variables[Galv_Key::VARIABLE] = 0
      end
    end
  end
end # Game_Player < Game_Character
 
 
class Window_KeyItem < Window_ItemList
   
  alias galv_key_item_key_window_on_ok on_ok
  def on_ok
    galv_key_item_key_window_on_ok
    $game_player.use_on_event
    clear_heading
  end
   
  alias galv_key_item_key_window_on_cancel on_cancel
  def on_cancel
    galv_key_item_key_window_on_cancel
    clear_heading
  end
   
  alias galv_key_item_key_window_start start
  def start
    puts "LAUNCHED"
    #SES::Tracer.stop
    if !$game_switches[Galv_Key::DISABLE_SWITCH]
      self.category = $game_system.key_item_cat
      draw_heading
      draw_gold_window
      update_placement
      refresh
      select(0)
      open
      activate
    else
      galv_key_item_key_window_start
    end
  end
  
  def draw_gold_window
    @gold_window = Window_Gold.new 
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = self.height
  end
   
  def draw_heading
    return if @heading != nil
    @heading = Sprite.new
    @heading.bitmap = Bitmap.new(Graphics.width, 25)
    @heading.bitmap.font.size = 25
    @heading.bitmap.font.color.set(text_color(0))
    @position = 0 if @position.nil?
    if Galv_Key::CATEGORIES.count > 1
      text = Galv_Key::CHANGE_CAT_LEFT + Galv_Key::CATEGORIES[@position][1] + Galv_Key::CHANGE_CAT_RIGHT
    else
      text = Galv_Key::CATEGORIES[@position][1]
    end
     
    @heading.bitmap.draw_text(@heading.bitmap.rect, text, 1)
     
    if @message_window.y >= Graphics.height / 2
      @heading.y = @message_window.height
    else
      @heading.y = Graphics.height - height + @message_window.height
    end
     
    @heading.z = z + 1
    @heading.opacity = 0
  end
   
  def clear_heading
    @gold_window.dispose
    @heading.dispose
    @heading.bitmap.dispose
    @heading = nil
  end
   
  def enable?(item)
    if !$game_switches[Galv_Key::DISABLE_SWITCH]
      true
    else
      super
    end
  end
   
  def update
    super
    @heading.opacity = openness if !@heading.nil?
    if self.active && Galv_Key::CATEGORIES.count > 1
      if Input.trigger?(Galv_Key::LEFT_BUTTON)
        Galv_Key::CATEGORIES.each_with_index do |c,i|
          @position = i if c[0] == $game_system.key_item_cat
        end
        @position -= 1
        @position = Galv_Key::CATEGORIES.count - 1 if @position < 0
        self.category = $game_system.key_item_cat = Galv_Key::CATEGORIES[@position][0]
        clear_heading
        draw_heading
        select(0)
      end
      if Input.trigger?(Galv_Key::RIGHT_BUTTON)
        Galv_Key::CATEGORIES.each_with_index do |c,i|
          @position = i if c[0] == $game_system.key_item_cat
        end
        @position += 1
        @position = 0 if @position >= Galv_Key::CATEGORIES.count
        self.category = $game_system.key_item_cat = Galv_Key::CATEGORIES[@position][0]
        clear_heading
        draw_heading
        select(0)
      end
    end
  end
 
end # Window_KeyItem < Window_ItemList
 
class Game_System
  attr_accessor :key_item_cat
   
  alias galv_key_item_system_initialize initialize
  def initialize
    galv_key_item_system_initialize
    @key_item_cat = Galv_Key::CATEGORIES[0][0]
  end
end