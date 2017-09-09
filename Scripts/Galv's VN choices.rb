#------------------------------------------------------------------------------#
#  Galv's Visual Novel Choices
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.9
#------------------------------------------------------------------------------#
#  2013-01-16 - Version 1.9 - Added Y offset for choice window
#  2012-11-28 - Version 1.8 - Z level setting added
#  2012-11-28 - Version 1.7 - Added compatability for some cursor scripts
#  2012-11-28 - Version 1.6 - Fixed a bug that could crash the game.
#  2012-11-28 - Version 1.5 - Added offset to change postion of cursor x and y
#  2012-11-28 - Version 1.4 - Fixed z levels and made cursor use an image
#  2012-11-27 - Version 1.3 - Fixed a bug with cancel choice selection
#  2012-11-27 - Version 1.2 - added a switch to disable script effects
#  2012-11-27 - Version 1.1 - added ability to use different image per choice
#                           - added a couple more options
#  2012-11-27 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  This script overwrites the default "Show Choices" list. The choices are
#  changed so they display centered on the screen with a graphic behind each
#  of them. Made with visual novel choice selection in mind.
#------------------------------------------------------------------------------#
#  INSTRUCTIONS:
#  Copy the graphic from the demo /Graphics/System into your project.
#  Copy the script into your script list, below Materials and above Main
#
#  Some setup options below, most only need to be changed if you use your own
#  custom choice image.
#------------------------------------------------------------------------------#
#  Codes:
#------------------------------------------------------------------------------#
#  Most of the usual codes that work in messages should work in choices.
#  (eg. \V[x], \N[x], \C[x], etc. Look at message tooltip to know more.)
#
#  A new one has been added so you can change the background image for separate
#  choice options.
#
#  \B[x]
#
#  This works by adding the number x (as you put in the code above) to the end
#  of the CHOICE IMAGE file name. For example, the default choice image is:
#  "Choice.png" located in /Graphics/System/. If you put the code anywhere in
#  a choice box:  \B[3]  it will look for "Choice3.png" image in the same
#  location.
#------------------------------------------------------------------------------#
 
($imported ||= {})["Galvs_Image_Choices"] = true
module Galv_Choice
 
#------------------------------------------------------------------------------#
#  SCRIPT SETUP OPTIONS
#------------------------------------------------------------------------------#
   
  CURSOR_IMAGE = "Cursor"  # Images used to determine which option you select
  CURSOR_OPACITY = 255      # Opacity of the cursor
  CURSOR_Y_OFFSET = 0       # Nudge cursor position vertically
  CURSOR_X_OFFSET = 0       # Nudge cursor position horizontally
 
  CHOICE_IMAGE = "Choice"   # Image for each choice located in /Graphics/System
  IMAGE_Y_OFFSET = 3        # Nudge your choice image vertically if needed
  IMAGE_OPACITY = 215       # The opacity of the image
 
  CHOICE_HEIGHT = 45        # How tall each choice.
  CHOICE_ITEM_Y = 2         # Offset for choice item text
   
  CENTER_TEXT = true        # left aligned if false, centered if true
                             
  DISABLE_SWITCH = 7        # Turn this switch ON to disable this script
   
  CHOICES_Y = 50             # Y offset to move choice window up or down.
                            # useful if you use a script that creates a namebox
  CHOICES_Z = 500            # The z value of the choices window. Try changing it
                            # if pictures or other scripts appear over or under
                            # the choices window to how you like.
   
#------------------------------------------------------------------------------#
  OTHER_Y_OFFSET = 12       # May fix other cursor scripts positioning
#------------------------------------------------------------------------------#
#  SCRIPT SETUP OPTIONS
#------------------------------------------------------------------------------#
 
end
 
class Window_ChoiceList < Window_Command
 
  alias galv_choice_initialize initialize
  def initialize(message_window)
    galv_choice_initialize(message_window)
    self.z = Galv_Choice::CHOICES_Z
  end
   
  def start
    @index = 0
    setup_choices
    make_cursor
    refresh
    open
    activate
    update_placement
    update_bgs
    refresh
    select(0)
  end
   
  def make_cursor
    return if $game_switches[Galv_Choice::DISABLE_SWITCH]
    @cursor_sprite = Sprite.new
    @cursor_sprite.bitmap = Cache.system(Galv_Choice::CURSOR_IMAGE)
  end
   
  def setup_choices
    @choice_sprite = []
    if !$game_switches[Galv_Choice::DISABLE_SWITCH]
      self.opacity = 0
      get_widths
    else
      self.opacity = 255
    end
  end
   
  alias galv_choice_update_placement update_placement
  def update_placement
    if $game_switches[Galv_Choice::DISABLE_SWITCH]
      galv_choice_update_placement
    else
      self.width = [max_choice_width + 12, 96].max + padding * 4
      self.width = [width, Graphics.width].min
      self.height = contents_height + Galv_Choice::CHOICE_HEIGHT - 10
      self.x = (Graphics.width - width) / 2
       
      self.y = (Graphics.height / 2) - contents_height + item_height / 2
    end
  end
 
  alias galv_choice_contents_height contents_height
  def contents_height
    if $game_switches[Galv_Choice::DISABLE_SWITCH]
      galv_choice_contents_height
    else
      (item_max + 1) * item_height
    end
  end
   
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text_ex(rect.x, rect.y, command_name(index))
    if !$game_switches[Galv_Choice::DISABLE_SWITCH]
      draw_bgs(index)
    end
  end
   
  def item_rect_for_text(index)
    rect = item_rect(index)
     
    if $game_switches[Galv_Choice::DISABLE_SWITCH]
      rect.x += 4
      rect.width -= 8
      rect
    else
      if Galv_Choice::CENTER_TEXT
        rect.x = (max_choice_width - @text_sizes.collect {|s| text_size(s).width }[index] + (padding * 3)) / 2
      else
        rect.x += 4
      end
      rect.width -= 8
      rect.y += Galv_Choice::CHOICE_ITEM_Y
      rect
    end
  end
   
  def get_widths
    @text_sizes = []
    @choice_background = []
    $game_message.choices.each_with_index do |c,i|
      @text_sizes[i] = esc_characters(c,i)
    end
  end
   
  def esc_characters(text,index)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { $game_actors[$1.to_i].name}
    result.gsub!(/\eP\[(\d+)\]/i) {
      if $game_party.members[$1.to_i].nil?
        ""
      else
        $game_party.members[$1.to_i].name 
      end
    }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result.gsub!(/\eC\[(\d+)\]/i)  { "" }
    result.gsub!(/\eI\[(\d+)\]/i)  { "   " }
    result.gsub!(/\eB\[(\d+)\]/i)  { @choice_background[index] = $1.to_i }
    result.gsub!(/\eB\[(\d+)\]/i)  { "" }
    result
  end
   
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result.gsub!(/\eB\[(\d+)\]/i)  { "" }
    result
  end
   
  def item_height
    return line_height if $game_switches[Galv_Choice::DISABLE_SWITCH]
    return Galv_Choice::CHOICE_HEIGHT
  end
   
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height - 15
    rect.height += 15 if $game_switches[Galv_Choice::DISABLE_SWITCH]
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
   
  def draw_bgs(index)
    return if @choice_sprite[index] != nil
     
    if @choice_background[index].nil?
      b = ""
    else
      b = @choice_background[index]
    end
    @choice_sprite[index] = Sprite.new
    @choice_sprite[index].bitmap = Cache.system(Galv_Choice::CHOICE_IMAGE + b.to_s)
    @choice_sprite[index].x = index % col_max * (item_width + spacing)
    @choice_sprite[index].y = index / col_max * item_height
    @choice_sprite[index].z = self.z - 2
  end
 
  def update_bgs
    @choice_sprite.each_with_index do |s,i|
      s.y = self.y + i * Galv_Choice::CHOICE_HEIGHT + Galv_Choice::IMAGE_Y_OFFSET
      s.x = (Graphics.width - s.width) / 2
      s.opacity = Galv_Choice::IMAGE_OPACITY
    end
  end
   
  def dispose_bgs
    @choice_sprite.each_with_index do |s,i|
      s.dispose
      s.bitmap.dispose
    end
    if !$game_switches[Galv_Choice::DISABLE_SWITCH]
      @cursor_sprite.dispose
      @cursor_sprite.bitmap.dispose
      @choice_sprite = []
    end
  end
   
  alias galv_choice_call_ok_handler call_ok_handler
  def call_ok_handler
    galv_choice_call_ok_handler
    dispose_bgs
  end
  alias galv_choice_call_cancel_handler call_cancel_handler
  def call_cancel_handler
    galv_choice_call_cancel_handler
    dispose_bgs
  end
   
  def update_cursor
    if $game_switches[Galv_Choice::DISABLE_SWITCH]
      super
    else
      cursor_rect.empty
      return if @cursor_sprite.nil? || @choice_sprite.nil?
      if @index < 0
        @cursor_sprite.opacity = 0
      else
        @cursor_sprite.opacity = Galv_Choice::CURSOR_OPACITY
        @cursor_sprite.x = @choice_sprite[@index].x + Galv_Choice::CURSOR_X_OFFSET
        @cursor_sprite.y = @choice_sprite[@index].y + Galv_Choice::CURSOR_Y_OFFSET
        @cursor_sprite.z = self.z - 1
        cursor_rect.y = (item_height * @index) + Galv_Choice::OTHER_Y_OFFSET
      end
    end
  end
 
end # Window_ChoiceList < Window_Command