module ImagePlayer_Config
  MAX_FRAMES_SEC = 0
  MIN_FRAMES_SEC = 4
  FRAME_STEP = 1
  INPUT_LOCK_TIMER = 60
  CUM_SE = ["Sex - Cumshot (4)",100,100] 
  BG_MUSIC = ["Groovy Baby",50,100]
  BG_MUSIC_2 = ["Crazy_la_Paint",100,100]
  MUSIC_SWITCH_ID = 113
  ACTOR_ID_VAR = 105
  DIALOGUE_LOCK_SWICTH = 105
  DIALOGUE_ROMANCE_LEVEL_VAR = 103
  SCENE_NAME_VAR = 102
  SCENE_OVERLAY_SWITCH = 106
  
   
  RND_SEX_SOUND = [ 
        ["Sex - Wet 3 (2)",80,100], 
        ["Sex - Wet 3 (3)",80,100], 
        ["Sex - Wet 3 (4)",80,100], 
        ["Sex - Wet 3 (5)",80,100], 
      ]
      
  RND_BJ_SOUND = [ 
        ["Sex - Wet 3 (2)",80,100], 
        ["Sex - Wet 3 (3)",80,100], 
        ["Sex - Wet 3 (1)",80,100], 
        ["Sex - Wet 3 (6)",80,100], 
      ]
 
  RND_MOAN_SOUND = [
  
  ]
  
  RND_SQUEAK_SOUND = [
  
  ]
  
  RND_HARDSLAP_SOUND = [
    ["sex - slap - soft",100,100],
    ["sex - slap - soft",100,115],
    ["sex - slap - soft",100,85]
  
  ]
  
  RND_SEX_SOUNDS = [RND_SEX_SOUND, RND_BJ_SOUND,RND_HARDSLAP_SOUND, RND_MOAN_SOUND, RND_SQUEAK_SOUND]
      
end

#Cache for scene folder
module Cache
  def self.scene(scene, filename)
      load_bitmap("Graphics/Scenes/" + scene + "/", filename)
  end
end 

include ImagePlayer_Config

class ImagePlayer < Scene_Base
  
  alias start_sceneplayer start
  alias term_sceneplayer terminate
  alias update_sceneplayer update
   
  def start
    $game_system.save_bgm
    start_sceneplayer  
          
    #Set up opening Vars
    @wait_var = MIN_FRAMES_SEC #Max frame tick
    @current_wait = MIN_FRAMES_SEC #Current frame tick 
    
    @new_scene = ""
    
    @image_id = 1 #Current Image to load
    @scene = $game_variables[SCENE_NAME_VAR] #Scene name
    @max_images = get_file_count #umber of images in scene group
    @sceneimage = Plane.new #load new image plane
    @sceneimage.z = -100 #set z number
    
    @foregroundimage = Plane.new
    @foregroundimage.z = 10
    
    
    
    @cum = false #Has user triggered cum input
    @currentlocktimer = 0 #Frames to lock input for
    
    @dialogue_script_lock = false #Is input locked while dialogue is on the screen
    @dialogue_script_level = 0 #Current level of dialogue to be displayed
    
    @dialogue_script = get_dialogue
    
    @max_progress = @dialogue_script.count - 2
    @current_progress = 0
    
    @max_speed = 5 #Default max speed
    @current_wait = @max_speed #Current frame tick  
    
    @no_dialogue = false
    @no_sound = false
    if @dialogue_script.count == 0 then
      @wait_var = 2
      @current_wait = 2
      @no_sound = true
      @no_dialogue = true
    end
    
    @new_speed = 0
    @new_sound = nil
    
    @skip_frame = 2
    
    @background = Sprite.new
    @background.bitmap = Cache.scene("Backgrounds", get_background_name)
    @background.z = -101
    
    #Play background music
    if $game_switches[MUSIC_SWITCH_ID] == true then
      RPG::BGM.new(BG_MUSIC_2[0],BG_MUSIC_2[1],BG_MUSIC_2[2]).play
    else
      RPG::BGM.new(BG_MUSIC[0],BG_MUSIC[1],BG_MUSIC[2]).play
    end
      
    @winhelpoverlay = SceneKeysHelp_Window.new
    
    show_dialogue
    
    update
  end
  

  def terminate
    super
    SceneManager.snapshot_for_background
    $game_system.replay_bgm
  end
  
  def update
    update_sceneplayer
    
    if @max_images == nil then
      return
    end
    
    #Allow player to exit scene with return
    if Input.repeat?(:B)
      RPG::BGM.fade(1)
      SceneManager.goto(Scene_Map)
      return
    end
    
    if @loop_enabled == false && @image_id >= @max_images && @new_scene == "" then
      if @current_progress <= @max_progress then
        show_dialogue
      end
      return
      
    end
    
    if @current_wait == @max_speed then
      if @skip_frame != 0 then
        @skip_frame = @skip_frame - 1
        @current_wait = @current_wait - 1
      else
        @skip_frame = 2
      end
    else
      #Reduce delay until netx frame is played
      @current_wait = @current_wait - 1
    end
       
    

    if @current_wait == 0 then     
      @current_wait = @max_speed #Need something like "current max wait"
      update_image
    end
    
    #If we have completed the scene, hang here until the return key has been pressed
    if @scenend == true then
        return
    end
      
    #If we ae locked due to shown dialogue return
    if $game_switches[DIALOGUE_LOCK_SWICTH] == true then
      return
    end
    
    if Input.repeat?(:RIGHT)
      #If we are at the max number of frames needed then return
      if @current_progress == @max_progress then
        return
      end
      
      @current_progress = @current_progress + 1
      show_dialogue
    #Enter key
    elsif Input.repeat?(:UP)
      #If we are on fastest speed - allow cum
      if @current_progress == @max_progress && $game_switches[DIALOGUE_LOCK_SWICTH] == false then
        show_dialogue
      end
    end
     
  end
  
  def update_image  
    
    if @image_id >= @max_images then
      @image_id = 1
      #If we have flagged to change the scene, change it at the end of the current one
      if @new_scene != nil && @new_scene != "" then
        @scene = @new_scene
        @max_images = get_file_count
        @new_scene = ""
        Cache.clear
      end
      
      if @new_speed > 0 then
        @max_speed = @new_speed
        @new_speed = 0
      end
      
      if @new_sound != nil then
        @sound_list.push @new_sound
        @new_sound = nil
      end
      
    else
      @image_id += 1  
    end
    
    
    #puts @scene + " (" + @image_id.to_s + ")"  
    
    #Cache.clear
    
    #Change image
    #@sceneimage.bitmap.dispose if @sceneimage.bitmap
    begin 
      @sceneimage.bitmap = Cache.scene(@scene, @scene + " (" + @image_id.to_s + ")"  )
    rescue  
      RPG::BGM.fade(1)
      SceneManager.goto(Scene_Map)
      $game_message.add("ERROR LOADING: " + @scene + " (" + @image_id.to_s + ")    IMAGE FILE")
      return
    end

    if @no_sound == false then
        check_sound_play
    end    
  end
  
  def get_background_name
    @dialogue_script.each do | script |
      #Change Background
      if match = script.match(/<command:background:(\w+_*)>/) then 
        background = match.captures[0]
        return background
      end  
    end
    return ""
  end
  
  def check_sound_play     
    @sound_list.each do | sound, frame|
      if frame == @image_id then
        #Play one of the random sounds
        if sound.match(/^\d+$/) then
          play_random_sound(sound.to_i)
        else
          play_sound(sound)
        end
      end    
    end    
  end
  
  def play_random_sound(sound_id)
      sound_list = RND_SEX_SOUNDS[sound_id]
    
      rnd = sound_list[rand(sound_list.count)]
      RPG::SE.new(rnd[0],rnd[1],rnd[2]).play
  end
    
  def play_sound(sound_string)
      sound_bits = sound_string.split("/")
      sound_bits.each do | test |
        puts test
      end
      RPG::SE.new(sound_bits[0],sound_bits[1].to_i,sound_bits[2].to_i).play
  end
  
  #Gets the count of files to give max image count
  def get_file_count(scene = @scene)
    
    file_found = true
    count = 1
    while file_found == true
      begin
        file = load_data("Graphics/Scenes/" + scene + "/" + scene + " (" + count.to_s + ").jpg")
      rescue 
        begin
          file = load_data("Graphics/Scenes/" + scene + "/" + scene + " (" + count.to_s + ").png")
        rescue
          return count - 1
        end
      end
      count = count + 1
    end
  end
    
  def show_dialogue 
    #Get the current dialogue line from the current dialogue level
    text = @dialogue_script[@dialogue_script_level]
    
    #If it's blank for whatever reason, just return don't display window
    if text == nil || text == "" then
      return
    end
    
    new_text = get_dialogue_commands(text)
    
    #Lock input due to dialogue display
    $game_switches[DIALOGUE_LOCK_SWICTH] = true
    
    #Show dialogue window
    @windialogue = SceneDialogue_Window.new(new_text)  

    #Increase the dialogue level
    @dialogue_script_level += 1
  end
  
  def get_dialogue_commands(text)
    if text.match(/<command:.+>/) then      
      #change view command
      if text.match(/<command:change_view:(\w+-*)+>/) then
        val = text.match(/<command:change_view:(\w+-*)+>/)[0]
     
        new_val = val.gsub(/<command:change_view:/, '')
        new_val = new_val.gsub(/>/,'') #Gets the scene to change to
        
        @new_scene = new_val
        
        text = text.gsub(/<command:change_view:(\w+-*)+>/, '')
      end  
      
      #play sound command (Name|Vol|Pitch|Frame)
      if match = text.match(/<command:play_sound:(.+)\|(\d+)\|(\d+)>/) then               
        RPG::SE.new(match.captures[0],match.captures[1].to_i,match.captures[2].to_i).play

        text = text.gsub(/<command:play_sound:(.+)\|(\d+)\|(\d+)>/, '')
      end  
      
      #insert sound command (Name|Vol|Pitch|Frame)
      if match = text.match(/<command:insert_sound:(.+\|\d+\|\d+)\|(\d+)>/) then  
        val = text.match(/<command:insert_sound:(.+\|\d+\|\d+)\|(\d+)>/)[0]

        sound = match.captures[0].gsub('|','/')
        frame = match.captures[1]
        
        if @new_scene == nil || @new_scene == "" then
          @sound_list.push [sound, frame.to_i] 
        else
          @new_sound = [sound, frame.to_i]
        end

        text = text.gsub(/<command:insert_sound:(.+\|\d+\|\d+)\|(\d+)>/, '')
      end  
      
      #Change animation speed command
      if match = text.match(/<command:change_speed:(\d+)>/) then 
        speed = match.captures[0]
        @new_speed = speed.to_i
        text = text.gsub(/<command:change_speed:(\d+)>/, '')
      end
      
      #Disable Loop
      if match = text.match(/<command:disable_loop>/) then 
        @loop_enabled = false
        text = text.gsub(/<command:disable_loop>/, '')
      end
      
      #Enable Loop
      if match = text.match(/<command:enable_loop>/) then 
        @loop_enabled = true
        text = text.gsub(/<command:enable_loop>/, '')
      end

      #Change Background
      if match = text.match(/<command:background:(\w+_*)>/) then 
        background = match.captures[0]
        @sceneimage.bitmap = Cache.scene("Backgrounds", background)
        text = text.gsub(/<command:background:(\w+_*)>/, '')
      end
      
      #Change Background
      if match = text.match(/<command:foreground:(\w+_*)>/) then 
        background = match.captures[0]
        @foregroundimage.bitmap = Cache.scene("Backgrounds", background)
        text = text.gsub(/<command:foreground:(\w+_*)>/, '')
      end
      
      if match = text.match(/<command:videorecord>/) then 
        @videorecord = Sprite.new
        @videorecord.bitmap = Cache.scene("Backgrounds", "PayMeOnOverlay")
        @videorecord.z = 1000
        text = text.gsub(/<command:videorecord>/, '')
      end
      
    end
    
    return text
  end
  
  def get_dialogue
    dialogue_lines = []
    
    #Open the CSV file based on the scene to pass in    
    #Read the file
    if $game_variables[ACTOR_ID_VAR] == 0 then
        path = "Data/Dialogues/Other/"  + @scene + ".csv"
      else
        path = "Data/Dialogues/" + $game_actors[$game_variables[ACTOR_ID_VAR]].name + "/" + @scene + ".csv"
      end
    
    begin
      file = load_data(path)        
    rescue 
      puts "failed to load: " + path
      $game_message.add("ERROR LOADING: " + @scene + ".csv")
      @sound_list = []
      return dialogue_lines
    end  
    
    #Split at new lines to get each level of dialogue for the relationship
    dialogue_levels = file.split("\n")
    
    @sound_list = set_sound_list(dialogue_levels[0])
    
    begin
      #Then split at the comma to get each dialogue fragment
      dialogue_lines = dialogue_levels[$game_variables[DIALOGUE_ROMANCE_LEVEL_VAR]].split(",")
    rescue
      RPG::BGM.fade(1)
      SceneManager.goto(Scene_Map)
      $game_message.add("ERROR LOADING Dialogue Level: " + $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR].to_s + ". For scene: " + @scene)
    end
    
    return dialogue_lines
  end
  
  
  ##Format should be:
  ##"Sound Name"/VOL/PITCH|FRAME_TO_PLAY_ON - OR
  ##RANDOM_SOUND_GROUP|FRAME_TO_PLAY_ON
  def set_sound_list(sound_list_string)  
    sound_list_strings = sound_list_string.split(",")
    
    @sound_list = [[]]
    
    sound_list_strings.each do | sound_string |
      sound_and_frame = sound_string.split("|")
      @sound_list.push [sound_and_frame[0], sound_and_frame[1].to_i]      
    end
    
    @sound_list.each do | sound, frame|
      puts sound
      puts frame.to_s
    end
  end
  
end

class SceneNameTag_Window < Window_Base
  
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize
    super(0,340, 1000,500)
    
    self.opacity = 255
    self.z = 1
    
    @name = ""
    
    refresh
  end
  
  def refresh
    contents.clear
    
    if @name == "" then
      self.hide
      return
    end
    
    draw_name
  end
  
  def update
    refresh
  end
 
  def draw_name 
    self.show
    
    contents.font.size = 50
    
    width = text_size(@name).width + 40
    height = text_size(@name).height + 50
    
    self.y = ((Graphics.height/5) * 4) - height
    self.width = width
    self.height = height
    
    draw_text(0,0,width, height, @name)
  end
  
  def update_window(name)
    @name = name
    refresh
  end
end

class SceneDialogue_Window < Window_Base
  
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize(text)
    super(0,(Graphics.height/5) * 4, Graphics.width,Graphics.height/5)
    self.opacity = 255
    self.z = 1000
    
    @text_lines = text.split("|")
    @line_count = @text_lines.count
    @current_line = 0
    
    @name_window = SceneNameTag_Window.new
    
    refresh
  end
  
  def refresh
    contents.clear
    draw_dialogue
  end
  
  def update   
    if Input.repeat?(:DOWN)
      @line_count = @line_count - 1
      
      if @line_count < 1 then
          #Unlock speed input and dispose of this text window
          $game_switches[DIALOGUE_LOCK_SWICTH] = false
          @name_window.dispose
          dispose
        else
          #Prepare the next time of text
          @current_line += 1       
          refresh
      end
    end
  end
 
  def draw_dialogue    
    line = @text_lines[@current_line]
    
    if line == nil || line == "" then
      return
    end
    
    if line.match(/<Red>/) then
      self.change_color(knockout_color)
      line = line.gsub(/<Red>/, "")
    else
      self.change_color(normal_color)
    end
    
    name_to_display = ""
    
    if line.match(/<N\d+>/) then
      val = line.match(/<N\d+>/)[0]
      
      number = val.match(/\d+/)[0]
      
      name_to_display = $game_actors[number.to_i].name                
      
      line = line.gsub(/<N\d+>/, "")
    end

    
    if name_to_display == "" && line.match(/(^<(\w+\s*\w*)>)/) then  
      matches = line.scan(/(^<(\w+\s*\w*)>)/)
      name_to_display = matches[0][1]            
      
      line = line.gsub(matches[0][0], "")
    end
    
    if line.match(/N<\d+>/) then
        values = line.scan(/N<\d+>/)
        max_count = values.size - 1

        for i in 0..max_count
          val = values[i].to_s.match(/\d+/)
       
          number = val[0]
          
          name = $game_actors[number.to_i].name 

          line = line.gsub(values[i].to_s, $game_actors[number.to_i].name)
        end
    end
  
    @name_window.update_window(name_to_display) 
    
    contents.font.size = 40

    #Removes white spacing
    line = line.strip
    
    draw_text(0,0,Graphics.width, Graphics.height/5, line)
  end
  
end

class SceneKeysHelp_Window < Window_Base
  
  #----------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------
  def initialize
    super(0,0, Graphics.width,Graphics.height)
    self.opacity = 0
    self.z = 1
    @input_delay = 0
    @input_lock = false
    refresh
  end
  
  def refresh
    contents.clear
    draw_help
  end
  
  def update   
    if @input_delay > 0 then
      @input_delay = @input_delay - 1
      return
    end
    
    if Input.press?(:L)
      if $game_switches[SCENE_OVERLAY_SWITCH] == true then
        $game_switches[SCENE_OVERLAY_SWITCH] = false
      else
        $game_switches[SCENE_OVERLAY_SWITCH] = true
      end
      refresh
      @input_delay = 60     
    end
  end
  
  def draw_help 
    file_name = "SceneOverlay"
    
    if $game_switches[SCENE_OVERLAY_SWITCH] == true then
      file_name = "SceneOverlayHidden"
    end
        
    bitmap = Cache.picture(file_name)
    rect = Rect.new(0, 0, Graphics.width, Graphics.height)
    contents.blt(0, 0, bitmap, rect, 255)
    bitmap.dispose
  end
  
  def terminate
    @overlay.bitmap.dispose
    @overlay.dispose
  end
  
end


class Game_Interpreter 
  
  #Easy script call
  def play_scene(scene_name, scene_count_var, actor_id, scene_id = 0)
    set_dialogue_level(scene_count_var, actor_id, scene_id)
    
    $game_variables[scene_count_var] += 1
    
    $game_variables[SCENE_NAME_VAR] = scene_name
    $game_variables[ACTOR_ID_VAR] = actor_id
    SceneManager.call(ImagePlayer)   
  end
  
  def set_dialogue_level(scene_count_var, actor_id, scene_id)
    
    if scene_id > 0 then
      $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR] = scene_id
    end
    
    if scene_count_var == 0 then
      $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR] = 1
      return
    end
    
    if $game_variables[scene_count_var] == 0 then
      $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR] = 1
      return
    end
    
    if actor_id == 0 then
      $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR] = 2
      return
    end
    
    actor_sex_level = return_sex_level($game_actors[actor_id].name) 
    
    dialog_lvl = actor_sex_level / 2
    
    if dialog_lvl < 2 then
      dialog_lvl = 2
    end
    
    $game_variables[DIALOGUE_ROMANCE_LEVEL_VAR] = dialog_lvl
    
    return
  end
  
end