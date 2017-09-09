#==============================================================================
# ** Text Input script
#------------------------------------------------------------------------------
# author:  erpicci
# version: 1.1rc
# require: CP Keyboard Input script by Neon Black
#
#------------------------------------------------------------------------------
# * Introduction
#------------------------------------------------------------------------------
# This script allows the player to insert a medium-sized text by typing
# directly from the keyboard. Inserted text is returned as a string.
#
# Requires Neon Black's Keyboard Input Script to work.
#
# It is completely free, both for commercial and non-commercial use. All you
# are asked to do is to give me credits for the script.
#
#------------------------------------------------------------------------------
# * Installation
#------------------------------------------------------------------------------
# Be sure to have Neon Black's Keyboard Input Script installed.
# Place this script in the "Materials" section of the scripts above main.
#
# To insert a text using an event, create a script event like:
#   text_var = text_input("Window Title")
#
# To have a script call the text input, use:
#   text_var = Scene_Text.read("Window Title")
#
# Only window title is mandatory. As optional arguments, you can set:
#  * alignment: "center" (default), "left", "right"
#  * maximum number of character: default is 104
#  * left-to-right: default is true, use false to get a right-to-left input
#
#------------------------------------------------------------------------------
# * Changelog and notes
#------------------------------------------------------------------------------
# -1.1rc: Added options to manipulate the text edit window (position, size,
#         opacity); manipulation is obtained through the new Scene_Text_Config
#         class. Backward compatibile.
#
#------------------------------------------------------------------------------
# * Examples
#------------------------------------------------------------------------------
#   # Open a window whose title is "Talk to Bobby", text is centered, allows
#   # to enter up to 20 characters, writing is right-to-left
#   variable = Scene_Text.read("Talk to Bobby", "center", 20, false)
#
#   # Open a window whose title is "Tell me something", text is aligned to
#   # right, allows to enter up to 88 characters, writing is left-to-right
#   # (default)
#   variable = Scene_Text.read("Talk to Bobby", "center", 20)
#
#   # Open a window whose title is "Insert text", text is centered (default),
#   # accepts up to 104 characters (default), writing is left-to-right (default)
#   variable = Scene_Text.read("Talk to Bobby")
#
#   # Open a window whose title is "Text:", text is centered, allows
#   # to enter up to 20 characters, writing is right-to-left,
#   # window is resized, centered in the screen and semi-transparent
#   config = Scene_Text_Config.new
#   config.width = 256
#   config.height = 128
#   config.verticalAlignment = "center"
#   config.horizontalAlignment = "center"
#   config.opacity = 64
#   variable = Scene_Text.read("Text:", "center", 20, true, config)
#
#   # Open a window whose title is "Text:", text is centered, allows
#   # to enter up to 30 characters, writing is right-to-left,
#   # window is resized, aligned on the top-right corner and fully transparent
#   config = Scene_Text_Config.new
#   config.width = 128
#   config.height = 256
#   config.verticalAlignment = "top"
#   config.horizontalAlignment = "right"
#   config.opacity = 0
#   variable = Scene_Text.read("Text:", "center", 30, true, config)
#==============================================================================
 
module Text_Input
  ACCEPTED_KEYS = {
    :k0 => 48, :k1 => 49, :k2 => 50, :k3 => 51, :k4 => 52,
    :k5 => 53, :k6 => 54, :k7 => 55, :k8 => 56, :k9 => 57,
   
    :kA => 65, :kB => 66, :kC => 67, :kD => 68, :kE => 69, :kF => 70,
    :kG => 71, :kH => 72, :kI => 73, :kJ => 74, :kK => 75, :kL => 76,
    :kM => 77, :kN => 78, :kO => 79, :kP => 80, :kQ => 81, :kR => 82,
    :kS => 83, :kT => 84, :kU => 85, :kV => 86, :kW => 87, :kX => 88,
    :kY => 89, :kZ => 90,
   
    :kCOLON     => 186, :kQUOTE     => 222, :kSPACE      => 32,
    :kCOMMA     => 188, :kPERIOD    => 190, :kSLASH      => 191,
    :kBACKSLASH => 220, :kLEFTBRACE => 219, :kRIGHTBRACE => 221,
    :kMINUS     => 189, :kEQUAL     => 187, :kTILDE      => 192,          
  }
end
 
 
 
#==============================================================================
# ** Scebe_Text_Config
#------------------------------------------------------------------------------
#  This object contains additional configuration for the text edit window
#==============================================================================
 
class Scene_Text_Config
  attr_accessor :lines
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :opacity
 
  #--------------------------------------------------------------------------
  # * Object Initialization: set default values
  #--------------------------------------------------------------------------
  def initialize
    @lines   = 6
    @x       = 0
    @y       = Graphics.height - window.fitting_height(lines)
    @width   = Graphics.width
    @height  = window.fitting_height(lines)
    @opacity = 256
  end
  #--------------------------------------------------------------------------
  # * Access to Properties of Windows
  #--------------------------------------------------------------------------
  def window
    Window_Base.new(0, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # * Sets Horizontal Alignment
  #--------------------------------------------------------------------------
  def horizontalAlignment=(position = "center")
    if (position == "left")
      @x = 0
    elsif (position == "right")
      @x = Graphics.width - @width
    else
      @x = (Graphics.width - @width) / 2
    end
  end
  #--------------------------------------------------------------------------
  # * Sets Vertical Alignment
  #--------------------------------------------------------------------------
  def verticalAlignment=(position = "bottom")
    if (position == "top")
      @y = 0
    elsif (position == "center")
      @y = (Graphics.height - @height) / 2
    else
      @y = Graphics.height - @height
    end
  end
end
 
 
 
#==============================================================================
# ** Scene_Text
#------------------------------------------------------------------------------
#  This class shows an input field for the player.
#==============================================================================
 
class Scene_Text < Scene_MenuBase
  ALIGN    = "center"
  MAX_CHAR = 104
  LTR      = true
 
  #--------------------------------------------------------------------------
  # * Show a dialog window to the player
  #--------------------------------------------------------------------------
  def self.read(title, align = ALIGN, max_char = MAX_CHAR, ltr = LTR, opts = nil)
    @@text     = ""
    @@title    = title
    @@align    = align
    @@max_char = max_char
    @@ltr      = ltr
    @@opts     = opts.nil? ? Scene_Text_Config.new : opts
    SceneManager.call(Scene_Text)
    Fiber.yield while SceneManager.scene_is?(Scene_Text)

    return @@text
  end
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @edit_window  = Window_TextEdit.new(@@title, @@align, @@max_char, @@ltr,
      @@opts)
    @edit_window.set_handler(:ok, method(:on_input_ok))
  end
  #--------------------------------------------------------------------------
  # * Set text when done
  #--------------------------------------------------------------------------
  def on_input_ok
    puts @edit_window.text
    @@text = @edit_window.text
    return_scene
  end
end
 
 
 
#==============================================================================
# ** Window_TextEdit
#------------------------------------------------------------------------------
#  This window allows to edit a text.
#==============================================================================
 
class Window_TextEdit < Window_Selectable
  include Text_Input
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :text
 
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(title, align = "center", max_char = 104, ltr = true, opts = nil)
    opts = opts.nil? ? Scene_Text_Config.new : opts
    super(opts.x, opts.y, opts.width, opts.height)
    self.opacity = opts.opacity
   
    @text     = ""
    @title    = title
    @align    = align
    @max_char = max_char
    @ltr      = ltr
    @opts     = opts
    @index    = @text.size
    activate
    refresh
  end
  #--------------------------------------------------------------------------
  # * Revert to Default Text
  #--------------------------------------------------------------------------
  def restore_default
    @text = ""
    @index = @text.size
    refresh
    return !@text.empty?
  end
  #--------------------------------------------------------------------------
  # * Get Character Width
  #--------------------------------------------------------------------------
  def char_width
    text_size($game_system.japanese? ? "‚ " : "A").width
  end
  #--------------------------------------------------------------------------
  # * Get Number of Columns
  #--------------------------------------------------------------------------
  def max_col
    [(@opts.width - 32) / char_width, @max_char].min
  end
  #--------------------------------------------------------------------------
  # * Get Left Padding
  #--------------------------------------------------------------------------
  def left(n)
    return 10                                if @align == "left"
    return (width - 32 - n * char_width)     if @align == "right"
    return (width - 32 - n * char_width) / 2 # if align == "center"
  end
  #--------------------------------------------------------------------------
  # * Get Rectangle for Displaying Item
  #--------------------------------------------------------------------------
  def item_rect(index)
    index -= 1 if index == @max_char
    x = index % max_col
    y = index / max_col
    n = [(@max_char - y * max_col), max_col].min
   
    x = left(n) + x * char_width
    x = width   - x - 48 if not @ltr
    y = 24      + y * (line_height + 4)
    Rect.new(x, y, char_width, line_height)
  end
  #--------------------------------------------------------------------------
  # * Get Underline Rectangle
  #--------------------------------------------------------------------------
  def underline_rect(index)
    rect = item_rect(index)
    rect.x += 1
    rect.y += rect.height
    rect.width -= 2
    rect.height = 2
    rect
  end
  #--------------------------------------------------------------------------
  # * Get Underline Color
  #--------------------------------------------------------------------------
  def underline_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * Draw Underline
  #--------------------------------------------------------------------------
  def draw_underline(index)
    contents.fill_rect(underline_rect(index), underline_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #--------------------------------------------------------------------------
  def draw_char(index)
    rect       = item_rect(index)
    rect.x     += 4
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @text[index] || "")
  end
  #--------------------------------------------------------------------------
  # * Draw Title
  #--------------------------------------------------------------------------
  def draw_title
    draw_text(0, 0, self.width, line_height, @title, 1)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_title
    @text.size.times {|i| draw_char(i) }
    @max_char.times  {|i| draw_underline(i) }
    cursor_rect.set(item_rect(@index))
  end
  #--------------------------------------------------------------------------
  # * Handle Process
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    process_delete if Input.repeat?(:kBACKSPACE)
    process_abort  if Input.trigger?(:kESC)
    process_ok     if Input.trigger?(:kENTER)
    process_keyboard
  end
  #--------------------------------------------------------------------------
  # * Check Input From Keyboard
  #--------------------------------------------------------------------------
  def process_keyboard
    ACCEPTED_KEYS.each {|key|
      if Input.repeat?(key[0])
        c = (key[0] != :kSPACE) ? Keyboard.add_char(Ascii::SYM[key[0]]) : " "
        process_add(c)
      end
    }
  end
  #--------------------------------------------------------------------------
  # * Add One Character
  #--------------------------------------------------------------------------
  def process_add(c)
    return if @index > @max_char
    if @index == @max_char
      @text[@index - 1] = c
    else
      @text  += c
      @index += 1
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Delete One Character
  #--------------------------------------------------------------------------
  def process_delete
    return if @index == 0
    @index -= 1
    @text  = @text[0, @index]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Abort Text Input
  #--------------------------------------------------------------------------
  def process_abort
    restore_default
    Sound.play_cancel
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # * Complete Text Input
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    call_ok_handler
  end
end
 
 
 
 
 
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Insert a text
  #--------------------------------------------------------------------------
  def text_input(title, align = "center", max_char = 103, ltr = true, opts = nil)
    Scene_Text.read(title, align, max_char, ltr, opts)
  end
end