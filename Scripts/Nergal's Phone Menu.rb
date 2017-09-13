
module Phone_Config
    POINTER_SPEED = 6
    
    LOWX = 182
    LOWY = 232
    
    HIGHX = 1073
    HIGHY = 735
    
    MAIN_UPPER_ICONS = ["message_icon","rel_icon","pic_icon","note_icon"]
    MAIN_LOWER_ICONS = ["settings_icon","save_icon"]
    CONTACT_ICONS_NAV = ["prev-icon","next-icon"]
    CONTACT_ICONS_RETURN = ["back-icon"]
    
    
    
    X_LOC_VAR = 22
    Y_LOC_VAR = 23
    
    CURRENT_ACTOR_VAR = 20
end


#-------------------------------------------------------------------------------
#  CACHE
#-------------------------------------------------------------------------------

module Cache
  def self.phone(filename)
    load_bitmap("Graphics/Phone/", filename)
  end
end # module Cache

#-------------------------------------------------------------------------------
#  PHONE SCENE
#-------------------------------------------------------------------------------

include Phone_Config

class Scene_Phone < Scene_Base
  def start
    super
    SceneManager.clear
    Graphics.freeze
    initialize_phone
  end
  
  def initialize_phone
    init_variables
    create_backdrop
    create_foreground
    #NTIC switched create_main_phone_menu and create_pointer
    create_main_phone_menu
    create_pointer
  end
  
  def init_variables
    @menu_type = 0
    @input_lock_timer = 0
    @icons = []
    $iconspointer = [] #NTIC
    return
  end
  
  def create_backdrop
    @backdrop = Sprite.new
    @backdrop.bitmap = Cache.phone("PhoneBackground-" + $game_variables[CURRENT_ACTOR_VAR].to_s)
    @backdrop.z = -1
  end
  
  def update_background(type)
    background = ""
    case type
    when 0 #main bg
      background = "PhoneBackground-" + $game_variables[CURRENT_ACTOR_VAR].to_s
    when 1 #contact list
      background = "ContactListBackground"
    when 2 #message list
      background = "MessageListBackground"
    else
      return
    end
    
    @backdrop.bitmap = Cache.phone(background)    
  end
  
  def create_foreground
    @foreground = Sprite.new
    @foreground.bitmap = Cache.phone("PhoneForeground")
    @foreground.z = 10
    @time_win = Time_Window.new     
  end
  
  def create_pointer
    @pointer = Sprite_Pointer.new(@viewport1)
  end
  
  def create_main_phone_menu
    dispose_current_icons
    @menu_type = 0
    update_background(0)
    create_icons(MAIN_UPPER_ICONS,LOWX+20,LOWY+80,20)
    create_icons(MAIN_LOWER_ICONS,HIGHX-250,HIGHY-120,20)
    @disposed = false
  end
  
  def create_contact_list_menu
    dispose_current_icons
    @menu_type = 1
    update_background(1)
    
    create_icons(CONTACT_ICONS_NAV,LOWX+420,LOWY+90,20)
    create_icons(CONTACT_ICONS_RETURN,LOWX+10,LOWY+70,20)
    create_icons(["send_message_icon"],LOWX+340,LOWY+75,20)
    @disposed = false
    
    draw_contact_list_window
  end
  
  def create_message_list_menu
    dispose_current_icons
    @menu_type = 2
    update_background(2)
    @disposed = false
    
    draw_message_list_window
  end
  
  def create_journal_list_menu
    dispose_current_icons
    @menu_type = 2
    update_background(2)
    @disposed = false
    
    draw_journal_list
    
  end
  
  def create_send_message_menu(actor_id)
    switch = actor_id + 120
    
    if $game_switches[switch] == false then
      FeedbackMsg.display_feedback("No Number")
      return
    end
    
    options = Text_Handler.get_player_send_text_options(actor_id)
    
    if options == nil || options.count == 0 then
      FeedbackMsg.display_feedback("No text options")
      return
    end
    
    dispose_current_icons
    @cl_win.dispose
    @menu_type = 2
    update_background(2)
    @disposed = false
    
    draw_send_message_options(options)
  end
    
  def draw_send_message_options(options)
    @ol_win = MessageOptionList_Window.new(options)
  end
  
  def create_icons(icon_list,x_start,y_start,x_gap)
    xgap = x_gap

    current_x = x_start
    current_y = y_start   
    
    icon_list.each do | string |
      new_icon = Sprite.new
      new_icon.bitmap = Cache.phone(string)
      new_icon.x = current_x
      new_icon.y = current_y
      new_icon.z = 1
      
      current_x = current_x + new_icon.bitmap.width + xgap 
      
      @icons.push new_icon
    end
    
    $iconspointer = @icons #NTIC
    
  end
  
  def draw_contact_list_window
    @cl_win = ContactList_Window.new
  end
  
  def draw_message_list_window
    messages = Text_Handler.get_all_available_texts
    
    if messages.count == 0 then
      return
    end
    
    @ml_win = MessageList_Window.new(messages)
  end
  
  def draw_journal_list
    entries = Journal_Handler.get_all_available_entries
    
    if entries.count == 0 then
      return
    end
    
    @jl_win = MessageList_Window.new(entries)
  end
  
  def update
    super
    
    update_pointer
    check_exit
    check_select
  end
  
  def update_pointer
    if @pointer then
      if
      @pointer.update
      end
    end
   
    if @menu_type == 0 || @menu_type== 1
      @pointer.visible = true
    else
      @pointer.visible = false
    end
  end
  
  def check_exit
    if Input.repeat?(:B)
      Sound.play_cancel
      if @menu_type != 0
        #dispose_graphics
        ##terminate
        ##contents.clear
        #if @cl_win
          #@cl_win.dispose
        #end
        #if @ml_win
          #@ml_win.contents.clear
          ##@ml_win.dispose_choices
        #end
        #if @jl_win
          #@jl_win.contents.clear
          #@jl_win.dispose_choices
        #end
        #initialize_phone
        SceneManager.goto(Scene_Map)
        SceneManager.goto(Scene_Phone)
      else
        SceneManager.goto(Scene_Map)
      end
    end
  end
  
  def check_select
    if @icons == nil
      return
    end
    
    if @input_lock_timer > 0 then
      @input_lock_timer = @input_lock_timer - 1
      return
    end
    
    within_icon_range = false
    selected_id = 0
    
    x = @pointer.x + (@pointer.bitmap.height / 2)
    y = @pointer.y
    count = 0
    
    if @disposed == false then
      @icons.each do | sprite |
        if x >= sprite.x && x <= sprite.x + sprite.width then
          if y >= sprite.y && y <= sprite.y + sprite.height then
              within_icon_range = true
              selected_id = count
              break
          end
        end

        count = count + 1
      end
    end
  
    if within_icon_range == false
      return
    end

    if Input.repeat?(:C)
      case @menu_type
      when 0
        input_main_menu_action(selected_id)
      when 1
        input_contact_list_action(selected_id)
      else
        return
      end
    end
  end
  
  def input_main_menu_action(action_id)
    case action_id
    when 0
      create_message_list_menu
    when 1
      if Rel_System.has_any_reps? == true then
        create_contact_list_menu
      end
    when 2
      SceneManager.call(Scene_CRM_Gallery)
    when 3
      create_journal_list_menu
    when 4
      SceneManager.call(Scene_Options)
    when 5
      SceneManager.call(Scene_Save)
    else
      SceneManager.goto(Scene_Map)
    end    
  end
  
  def input_contact_list_action(action_id)
    case action_id
    when 0
      @cl_win.decrease_index #prev contact
      @input_lock_timer = 30
    when 1
      @cl_win.increase_index #next contact
      @input_lock_timer = 30
    when 2
      @cl_win.dispose
      create_main_phone_menu
    when 3
      create_send_message_menu(@cl_win.actor_index)
      #@cl_win.send_message
    else
      SceneManager.goto(Scene_Map)
    end    
  end
  
  def terminate  
    super
    SceneManager.snapshot_for_background
    $iconspointer = nil
    dispose_graphics
  end
  
  def dispose_graphics 
    @backdrop.bitmap.dispose
    @backdrop.dispose
    @pointer.bitmap.dispose
    @pointer.dispose
    @foreground.bitmap.dispose
    @foreground.dispose
    dispose_current_icons
   
  end
  
  def dispose_current_icons
    @disposed = true
    @icons.each do | sprite |
      sprite.bitmap.dispose
      sprite.dispose
    end 
    @icons.clear #NTIC
  end
  
end



#-------------------------------------------------------------------------------
#  POINTER SPRITE
#-------------------------------------------------------------------------------

class Sprite_Pointer < Sprite
  def initialize(viewport, x_loc_var = X_LOC_VAR,y_loc_var = Y_LOC_VAR, lowx = LOWX, lowy = LOWY, highx = HIGHX, highy = HIGHY, speed = POINTER_SPEED)
    super(viewport)
    
    @x_loc_var = x_loc_var
    @y_loc_var = y_loc_var
    @lowx = lowx
    @highx = highx
    @highy = highy
    @speed = speed
    
    @icon_array_index = 0 #NTIC
    
    init_position
  end
  
  def init_position
    setup_pointer
  end

  def dispose
    $game_variables[@x_loc_var] = self.x
    $game_variables[@y_loc_var] = self.y
	
    super
  end

  def update
    super
    update_position
  end
  
  def setup_pointer
    self.bitmap = Cache.phone("pointer")
    
    self.x = $game_variables[@x_loc_var]
    self.y = $game_variables[@y_loc_var]
    
    x = Graphics.width/2
    
    if $game_variables[@x_loc_var] > 0 then
        x = $game_variables[@x_loc_var]
    end
    
    y = Graphics.height/2 
    
    if $game_variables[@y_loc_var] > 0 then
        y = $game_variables[@y_loc_var]
    end
    
    if $iconspointer != nil 
      self.x = $iconspointer[0].x + $iconspointer[0].bitmap.width/2
      self.y = $iconspointer[0].y + $iconspointer[0].bitmap.height/2
    else
      self.x = x
      self.y = y
    end
    
    self.z = 10
  end

  def width
    self.bitmap.width
  end
  def height
    self.bitmap.height
  end
  
  def update_position
    if $iconspointer != nil
      if $iconspointer.length < 1
        return
      end
      
      if Input.repeat?(:RIGHT) && !Input.repeat?(:LEFT) && @icon_array_index <= ($iconspointer.length - 1)
        if @icon_array_index == ($iconspointer.length - 1)
          @icon_array_index = 0
        else      
          @icon_array_index = @icon_array_index + 1
        end
        xPosition = $iconspointer[@icon_array_index].x + $iconspointer[@icon_array_index].bitmap.width/2
        yPosition = $iconspointer[@icon_array_index].y + $iconspointer[@icon_array_index].bitmap.height/2
        self.x = xPosition 
        self.y = yPosition       
      elsif Input.repeat?(:LEFT) && !Input.repeat?(:RIGHT) && @icon_array_index >= 0 #NotThatICare
        if @icon_array_index == 0
          @icon_array_index = $iconspointer.length - 1
        else
          @icon_array_index = @icon_array_index - 1
        end
        xPosition = $iconspointer[@icon_array_index].x + $iconspointer[@icon_array_index].bitmap.width/2
        yPosition = $iconspointer[@icon_array_index].y + $iconspointer[@icon_array_index].bitmap.height/2
        self.x = xPosition 
        self.y = yPosition 
      end
    else
      
      if Input.press?(:LEFT) && !Input.press?(:RIGHT)
        self.x -= @speed if self.x > @lowx 
      elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
        self.x += @speed if self.x < @highx  - width
      elsif Input.press?(:UP) && !Input.press?(:DOWN)
        self.y -= @speed if self.y > @lowx 
      elsif Input.press?(:DOWN) && !Input.press?(:UP)
        self.y += @speed if self.y < @highy - height
      end
    end
    
  end
end # Sprite_Pointer < Sprite

#-------------------------------------------------------------------------------
#  CONTACT LIST WINDOW
#-------------------------------------------------------------------------------

class ContactList_Window < Window_Selectable
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize
    super(0,0, Graphics.width,Graphics.height)
    self.opacity = 0
    self.z = 0   
    
    @actor_ids = Rel_System.return_current_char_romance_ids
    @max_count = @actor_ids.count - 1
    @index = 0
    @actor_id = @actor_ids[@index]
    @actor_name = $game_actors[@actor_id].name
    
    @potrtrait = Sprite.new
    
    refresh
  end
  
  def actor_index
    return @actor_id
  end
  
  def increase_index
    if @index == @max_count then
      @index = 0
    else
      @index = @index + 1
    end
    change
  end
  
  def decrease_index
    if @index == 0 then
      @index = @max_count
    else
      @index = @index - 1
    end
    change
  end
  
  def refresh
    contents.clear
    draw_portrait
    draw_act_name
    draw_rel_level
    draw_corr_level
    draw_sex_level
  end
  
  def change
    @actor_id = @actor_ids[@index]
    @actor_name = $game_actors[@actor_id].name
    refresh
  end
  
  def update   
  end
   
  def draw_portrait 
    begin
      actor_name = @actor_name

      if @actor_id == 5 then
        actor_name = "MsAmos"
      end
      
      if Rel_System.return_sex_level(@actor_name) == 10 then
        @potrtrait.bitmap = Cache.busts(actor_name + "-nude-4")
      elsif Rel_System.return_sex_level(@actor_name) >= 6 then
        @potrtrait.bitmap = Cache.busts(actor_name + "-4")
      else
        @potrtrait.bitmap = Cache.busts(actor_name + "-1")
      end
    rescue
      return
    end
    @potrtrait.z = 1
    @potrtrait.x = LOWX -  20
    @potrtrait.y = HIGHY - (@potrtrait.height * 0.45)
    @potrtrait.zoom_x = 0.45
    @potrtrait.zoom_y = 0.45
  end
  
  def draw_act_name
    name = @actor_name
    
    contents.font.size = 50
    
    width = text_size(name).width#@textsize.width
    height = text_size(name).height
    
    change_color(text_color(15))
    draw_text((HIGHX-190)-(width/2),LOWY+80,width,height,name)
  end
  
  
  def draw_rel_level
    rel_level = Rel_System.return_rep(@actor_name)
    draw_gauge(HIGHX-380,LOWY+190,350,rel_level.to_f/NergRel::MAX_RELATIONSHIP,text_color(27),text_color(30))
    oldfontsize = contents.font.size
    contents.font.size = 30
    textthing = "/100"
    draw_text(HIGHX-100,LOWY+170,text_size(textthing).width,text_size(textthing).height,textthing, 2)
    draw_text(HIGHX-150,LOWY+170,text_size(textthing).width,text_size(textthing).height,rel_level, 2)
    contents.font.size = oldfontsize
  end
  
  def draw_corr_level
    cor_level = Rel_System.return_corruption(@actor_name)
    draw_gauge(HIGHX-380,LOWY+280,350,cor_level.to_f/NergRel::MAX_CORRUPTUION,text_color(10),text_color(18))
    oldfontsize = contents.font.size
    contents.font.size = 30
    textthing = "/100"
    draw_text(HIGHX-100,LOWY+260,text_size(textthing).width,text_size(textthing).height,textthing, 2)
    draw_text(HIGHX-150,LOWY+260,text_size(textthing).width,text_size(textthing).height,cor_level, 2)
    contents.font.size = oldfontsize
  end
  
  def draw_sex_level
    
    if @actor_id == 4 then
      sex_lvl = $game_variables[1004]
    else
      sex_lvl = Rel_System.return_sex_level(@actor_name).to_s
    end
    
    contents.font.size = 70
    
    width = text_size(sex_lvl).width#@textsize.width
    height = text_size(sex_lvl).height
    
    change_color(text_color(0))
    draw_text((HIGHX-270)-(width/2)+40,HIGHY-130,width,height,sex_lvl)
  end
  
  
  def display_feedback(message)    
      max_x = Graphics.width / 2
      max_y = Graphics.height / 2
       
      @win_feedback = Window_Base.new(max_x, max_y, width, height)
      @win_feedback.opacity = 0
      @win_feedback.z = 15
      
      Audio.se_play("Audio/SE/Buzzer1", 80, 100)
      
      @win_feedback.contents.font.size = 40
      text_width = @win_feedback.contents.text_size(message).width
      text_height = @win_feedback.contents.text_size(message).height
      
      @win_feedback.width = text_width + 40
      @win_feedback.height = text_height * 2
      @win_feedback.x = max_x - (@win_feedback.width / 2)
      @win_feedback.y = max_y - (@win_feedback.height / 2)

      @win_feedback.draw_text(0, 0, text_width+400, text_height, message)
      
      fade_out = 60
      i = fade_out
    
      while i > 0 do
        @win_feedback.opacity = @win_feedback.contents_opacity =  i * (256/fade_out)
        @win_feedback.update
        Graphics.update
        i = i - 1
      end
      
      @win_feedback.dispose
  end
  
  def dispose
    contents.dispose unless disposed?
    @potrtrait.bitmap.dispose
    @potrtrait.dispose
    super
  end
  
end # ContactList_Window < Window_Base

#-------------------------------------------------------------------------------
#  MESSAGE LIST WINDOW
#-------------------------------------------------------------------------------

class MessageList_Window < Window_Selectable
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize(message_list)
    super(LOWX,LOWY, Graphics.width,Graphics.height)
    self.opacity = 0
    self.z = 0  
    
    @message_list = message_list 
    
    puts @message_list
    
    @index = 0
    @max = @message_list.count - 1
    
    @view_height = HIGHY - LOWY - 65
    @view_width =  HIGHX - LOWX
    @view_y_start = LOWY + 65
    
    @message_height = @view_height / 3
    @message_width = @view_width
    
    @scrolling = false
    @up = false
    @down = false
    @to_scroll = 0
    
    refresh
  end
  
  def get_dummy_list
    list = []
    
    list.push ["Mom", "Hey Dear"]
    list.push ["Sydney" , "Fuck you!"]
    list.push ["Mrs Jennings", "Tonight. My Place."]
    list.push ["Test", "Test Pos 4"]
    list.push ["Test 2", "Test Pos 5"]
    
    return list
    
  end
  
  def increase_index
    if @index == @max then
      @index = 0
    else
      @index = @index + 1
    end
  end
  
  def decrease_index
    if @index == 0 then
      @index = @max
    else
      @index = @index - 1
    end
  end
  
  def refresh
    contents.clear
    draw_list
  end
  
  def scroll_change
    refresh
  end
  
  def update 
    if @max < 1 then
      return
    end
    
    if @scrolling == true then      
      scroll_amount = 10
      
      if @to_scroll < scroll_amount then
        scroll_amount = @to_scroll
      end
      
      if @up == true then
        @messages.each do | message |
          message.y = message.y - scroll_amount
        end
      end
      if @down == true then
        @messages.each do | message |
          message.y = message.y + scroll_amount
        end
      end
      @to_scroll = @to_scroll - scroll_amount
      if @to_scroll == 0 then
        @scrolling = false
        if @up == true then
          set_old_selected_to_bottom
        end
      end
      return #Don't allow input
    end
    
    if @max < 3 then
      if Input.repeat?(:UP)
        decrease_index
        set_all_windows_unselected
        @messages[@index].select_this
      end
      if Input.repeat?(:DOWN)
        increase_index
        set_all_windows_unselected
        @messages[@index].select_this
      end
      return
    end
    
    if Input.repeat?(:DOWN)
      scroll_messages(true)
      increase_index
      set_all_windows_unselected
      @messages[@index].select_this
    end
    
    if Input.repeat?(:UP)
      set_new_selected_to_top
      scroll_messages(false)
      decrease_index
      set_all_windows_unselected
      @messages[@index].select_this
    end
    
  end
  
  def scroll_messages(up)
    @to_scroll = @message_height
    
    if up == true then
      @up = true
      @down = false
    else
      @down = true
      @up = false
    end
    
    @scrolling = true
  end
  
  def set_all_windows_unselected
    @messages.each do | message |
      message.unselect_this
    end
  end
   
  def draw_list  
    @messages = []
    y_pos = @view_y_start
    selected = true
    for i in 0..@max
      sender = @message_list[i][0]
      msg_short = @message_list[i][1]
      @messages.push TextMessage_Window.new(sender,msg_short,LOWX,y_pos,@message_width,@message_height, selected)      
      y_pos = y_pos + @message_height
      selected = false      
    end
    
  end
  
  def set_old_selected_to_bottom
    index_to_move = @index - 1
    if index_to_move < 0 then
      index_to_move = @max
    end
    @messages[index_to_move].y = @messages[@index].y + (@max * @message_height)
  end
  
  def set_new_selected_to_top
    index_to_move = @index - 1
    if index_to_move < 0 then
      index_to_move = @max
    end
    @messages[index_to_move].y = @messages[@index].y - @message_height
  end
    
end # MessageList_Window < Window_Base


#-------------------------------------------------------------------------------
#  Text Message WINDOW
#-------------------------------------------------------------------------------

class TextMessage_Window < Window_Selectable
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize(sender, message_short,x,y,width,height, selected = false)
    super(x,y, width,height)
    @selected = selected
    if @selected == true then
      self.opacity = 125
    else
      self.opacity = 0
    end
    
    self.z = 1
    
    @sender = sender
    @message_short = message_short

    refresh
  end
  
  def refresh
    contents.clear 
    if @selected == true then
      self.opacity = 125
    else
      self.opacity = 0
    end
    draw_sender
    draw_short_message
    #draw_divider
  end

  def draw_sender
    contents.font.size = 40
    change_color(text_color(15))
    width = text_size(@sender).width
    @sender_height = text_size(@sender).height
    draw_text(30,5,width,@sender_height,@sender)
  end
  
  def draw_short_message
    contents.font.size = 30
    change_color(text_color(7))
    width = text_size(@message_short).width
    height = text_size(@message_short).height
    draw_text_ex(30,@sender_height+5,@message_short)
  end

  def draw_divider
    @divide = Sprite.new
    @divide.bitmap = Cache.phone("MessageDivider")
    @divide.x = self.x
    @divide.y = self.y + self.height - 10
    @divide.z = 1
    @divide = nil
  end
  
  def select_this
    @selected = true
    refresh
  end
  
  def unselect_this
    @selected = false
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end

  
end # TextMessage_Window < Window_Base


#-------------------------------------------------------------------------------
#  MESSAGE OPTION LIST WINDOW
#-------------------------------------------------------------------------------

class MessageOptionList_Window < Window_Selectable
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize(options)
    super(LOWX,LOWY, Graphics.width,Graphics.height)
    self.opacity = 0
    self.z = 0  
    
    @message_options = options
    
    puts @message_options
    
    @index = 0
    @max = @message_options.count - 1
    
    @showing_text = false
    
    @win_choices = []
    
    draw_options
    #refresh
  end
  
  def increase_index
    if @index == @max then
      @index = 0
    else
      @index = @index + 1
    end
    #refresh
  end
  
  def decrease_index
    if @index == 0 then
      @index = @max
    else
      @index = @index - 1
    end
    #refresh
  end
  
  def update 
    if @max < 0 || @showing_text == true then
      return
    end
    
    if Input.repeat?(:DOWN)
      increase_index
      set_all_windows_unselected
      @win_choices[@index].select_this
    end
    
    if Input.repeat?(:UP)
      decrease_index
      set_all_windows_unselected
      @win_choices[@index].select_this
    end
    
    if Input.repeat?(:C) then
      dispose_choices
      
      if @message_options[@index][2] > 0 then
        $game_switches[@message_options[@index][2]] = true
      end
  
      message = @message_options[@index][1]
      
      @win_sent_text = MessageDisplay_Window.new(LOWX,LOWY+60,HIGHX-LOWX - 40,HIGHY-LOWY-60)
      @win_sent_text.opacity = 0
      @win_sent_text.z = 15
      
      Audio.se_play("Audio/SE/computer_instant_message_alert_01", 80, 100)
      
      @win_sent_text.contents.font.size = 40
      
      @win_sent_text.contents.font.color = Color.new(0,0,0,255)
      
      text_width = @win_sent_text.contents.text_size(message).width
      text_height = @win_sent_text.contents.text_size(message).height
      
      @win_sent_text.draw_text_ex(0, 0, message)
      
      @showing_text = true      
    end
    
  end
  
  def set_all_windows_unselected
    @win_choices.each do | message |
      message.unselect_this
    end
  end
   
  def draw_options  
   
    options = @message_options
    
    screen_height = HIGHY - LOWY - 60
    screen_width = HIGHX - LOWX
    
    option_height = screen_height / options.count
    if option_height > screen_height / 4 then
      option_height = screen_height / 4
    end
    option_width = screen_width / 2
    start_x = (Graphics.width/2) - (option_width / 2)
    start_y = (LOWY + (screen_height/2)) - ((option_height * options.count) / 2) + 60
    cur_y = start_y
 
    select_choice = false
    
    for i in 0..options.count - 1
      if i == @index then
        select_choice = true
      else
        select_choice = false
      end

      @win_choices.push TextChoice_Window.new(@message_options[i][0],start_x,cur_y,option_width,option_height, select_choice)
      cur_y = cur_y + option_height
    end
        
  end
  
  def dispose_choices
    @win_choices.each do | message | 
      message.dispose
    end
  end
    
end # MessageOptionList_Window < Window_Base

#-------------------------------------------------------------------------------
#  Text Choice WINDOW
#-------------------------------------------------------------------------------

class TextChoice_Window < Window_Selectable
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize(short_text, x,y,width,height, selected = false)
    super(x,y, width,height)
    @selected = selected
    if @selected == true then
      self.opacity = 185
    else
      self.opacity = 0
    end
    
    self.z = 1
    
    @short_text = short_text

    refresh
  end
  
  def refresh
    contents.clear 
    if @selected == true then
      self.opacity = 185
    else
      self.opacity = 0
    end
    draw_short_text
  end

  def draw_short_text
    contents.font.size = 40
    change_color(text_color(15))
    width = text_size(@short_text).width
    height = text_size(@short_text).height
    draw_text(30,5,width,height,@short_text)
  end

  
  def select_this
    @selected = true
    refresh
  end
  
  def unselect_this
    @selected = false
    refresh
  end

  
end # TextChoice_Window < Window_Base


#-------------------------------------------------------------------------------
#  MessageDisplay_Window WINDOW
#-------------------------------------------------------------------------------


class MessageDisplay_Window < Window_Base
    
  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  
end # MessageDisplay_Window < Window_Base

#-------------------------------------------------------------------------------
#  TIME WINDOW
#-------------------------------------------------------------------------------


class Time_Window < Window_Base
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize
    super(0,0, Graphics.width,Graphics.height)
    self.opacity = 0
    self.z = 5000   
    
    draw_time
    draw_date
  end
  
  def draw_time
    time_string = Day_Time.get_phone_time
    
    contents.font.size = 40
    
    width = text_size(time_string).width
    height = text_size(time_string).height
    
    change_color(text_color(0))
    draw_text((HIGHX + width) / 2,LOWY-10,width,height,time_string)
  end
  
  def draw_date
    date_string = Day_Time.get_phone_date
    
    contents.font.size = 40
    
    width = text_size(date_string).width
    height = text_size(date_string).height
    
    change_color(text_color(0))
    draw_text(LOWX,LOWY-10,width,height,date_string)
  end

  
end # ContactList_Window < Window_Base