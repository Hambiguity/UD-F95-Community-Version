module PayMeOn_Config
  
  POINTER_SPEED = 10
  X_LOC_VAR = 24
  Y_LOC_VAR = 25
  
  TITLE_VAR = 26
  BIO_VAR = 27
  
  MAX_TO_SHOW = 9
  GRID_WIDTH = 3
  
  PHOTO_SWITCH_ID_START = 201
  MAX_TO_CHECK = 50
  
  IMAGE_ZOOM = 0.2
  
  ADDITION_SWITCH_STORE = 1000
  
  DOLLAR1_PLEDGE_VAR = 28
  DOLLAR5_PLEDGE_VAR = 29
  
  DOLLAR1_INCREASE_VAR = 30
  DOLLAR5_INCREASE_VAR = 31
  
  TOTAL_MONTH_GAIN = 32
  
  SOLO_IMGS_SWITCHES = [217,201,207,208,204,211,212,218,216,205,222,202,203,215]
  
  BACKGROUND_IMG_VAR = 33
  
  VID_SWITCHES = [
        [702,"DizzyBabysitting"],
        [703,"MsAmosBedRiding"],
  
  
  ]
  
end

module Cache
  def self.paymeon(filename)
    load_bitmap("Graphics/PayMeOn/", filename)
  end
end # module Cache

include PayMeOn_Config


class Scene_PayMeOn < Scene_Base
  
  def start
    super
    SceneManager.clear
    Graphics.freeze
    initialize_paymeon
  end
  
  
  def initialize_paymeon
    @icons = []
    @current_screen = 0
    @display_images = []
    @display_images_switches = []
    @uploading = false
    @rand = Random.new
    
    create_pointer   
    
    @mainscreen = Sprite.new
    display_main_screen
    draw_sections
    create_actions
  end
  
  def draw_scene
    display_main_screen
    draw_sections
    create_actions
  end
  
  
  def display_main_screen
    case @current_screen
    when 0 
      @mainscreen.bitmap = Cache.paymeon("PayMeOnScreen")
      @mainscreen.z = 2 
    when 1 #new post
      @mainscreen.bitmap = Cache.paymeon("NewPostScreen")
      @mainscreen.z = 2 
    when 2
      @mainscreen.bitmap = Cache.paymeon("EditBannerScreen")
      @mainscreen.z = 2 
    else
      return
    end
  end
  
  def draw_sections
    case @current_screen
    when 0 
      draw_reward_progress
      draw_title_and_bio
      draw_banner
    when 1 #new post
      return 
    when 2
      return
    else
      return
    end
    
    @disposed = false
  end
  
  def create_pointer
    @pointer = Sprite_Pointer.new(@viewport1, X_LOC_VAR, Y_LOC_VAR, 0, 0, Graphics.width,Graphics.height, POINTER_SPEED)
  end
  
  
  def create_actions
    @icons = []
    
    case @current_screen
    when 0 
      place_icon("home",Graphics.width-60,5) #Home
      place_icon("newpost",8,53) #New Post
      place_icon("edit",Graphics.width-142, 55) #Edit Banner
    when 1 #new post
      place_icon("home",Graphics.width-60,5) #Home
      place_icon("newpost",8,53) #New Post
      place_icon("TextIcon",400 , 170) #Post Text
      place_icon("ImageIcon",600, 170) #Post Image
      place_icon("MovieIcon",800, 170) #Post Movie
    when 2
      place_icon("home",Graphics.width-60,5) #Home
      place_icon("newpost",8,53) #New Post
      place_icon("GroupIcon",400 , 170) #Create Group Banner
      place_icon("SexIcon",700, 170) #Create Single Banner
    else
      return
    end
    
    @disposed = false
  end
  
  def draw_banner
      if $game_variables[BACKGROUND_IMG_VAR] == 0 || $game_variables[BACKGROUND_IMG_VAR] == "" then
        return
      end
      
      @banner = Sprite.new
      @banner.bitmap = Cache.gallery($game_variables[BACKGROUND_IMG_VAR])
      @banner.z = 0
      @banner.x = 0
      @banner.y = -50
      #@banner.zoom_x = zoom
      @banner.zoom_y = 0.7
  end
    
  def draw_reward_progress
    
    #Reward Bar
    width = 270
    height = 80
    x = 120
    y = 798

    current_gain = $game_variables[TOTAL_MONTH_GAIN].to_f

    @reward = Window_Base.new(x, y, width, height)
    @reward.z = 50
    @reward.opacity = 0 
    
    @reward.draw_gauge(0,0,width,current_gain/1000.to_f,@reward.text_color(2),@reward.text_color(20))
    
    #Pledger Section
    width = 270
    height = 220
    x = 120
    y = 540

    current_gain = $game_variables[TOTAL_MONTH_GAIN].to_f

    @pledgers = Window_Base.new(x, y, width, height)
    @pledgers.z = 50
    @pledgers.opacity = 0 
    
    @pledgers.draw_text_ex_extra(0,0,($game_variables[DOLLAR1_PLEDGE_VAR] + $game_variables[DOLLAR5_PLEDGE_VAR]).to_s,15,60)
    @pledgers.draw_text_ex_extra(0,50,"pledgers",7,30)
    @pledgers.draw_text_ex_extra(0,120,"$" + $game_variables[TOTAL_MONTH_GAIN].to_s,15,60)
    @pledgers.draw_text_ex_extra(0,170,"per month",7,30)

  end
  
  def draw_title_and_bio
      if $game_variables[TITLE_VAR] == 0 then
        $game_variables[TITLE_VAR] = "URBAN DEMON"
      end
    
      name = $game_variables[TITLE_VAR]
       
      @title = Window_Base.new(268, 461, 540, 500)
      @title.opacity = 0
      @title.z = 5

      text_width = @title.contents.text_size(name).width
      text_height = @title.contents.text_size(name).height
      @title.draw_text_ex_extra(0,0,name,2,40)
   
      
      if $game_variables[BIO_VAR] == 0 then
        $game_variables[BIO_VAR] = "I'm the Urban Demon, Peter, and I'm here to fuck milfs!"
      end
         
      message = $game_variables[BIO_VAR]
       
      @bio = Window_Base.new(400, 600, 540, 500)
      @bio.opacity = 0
      @bio.z = 5

      text_width = @bio.contents.text_size(message).width
      text_height = @bio.contents.text_size(message).height
      @bio.draw_text_ex_extra(0,0,message,15)
   
  end
  

  def update
    super
    
    if @uploading == true then
      update_upload
      return
    end
    
    update_pointer
    check_exit
    check_icon_select
    check_img_select
  end
  
  def update_pointer
    if @pointer then
      @pointer.update
    end
  end
  
  def check_exit
    if Input.press?(:B)
      SceneManager.goto(Scene_Map)
    end
  end
  
  def check_icon_select
    if @icons == nil
      return
    end
    
    within_icon_range = false
    within_img_range = false
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

    if Input.repeat?(:C) && within_icon_range == true
      case @current_screen
      when 0 #Home
        exe_action_home(count)
      when 1 #new post
        exe_action_new(count)
      when 2 #edit banner
        exe_action_ban(count)
      end
    end
  end
  
  def check_img_select
    if @display_images == nil
      return
    end
    
    within_icon_range = false
    within_img_range = false
    selected_id = 0
    
    x = @pointer.x + (@pointer.bitmap.height / 2)
    y = @pointer.y
    count = 0
    
    if @disposed == false then
      @display_images.each do | sprite |
        if x >= sprite.x && x <= sprite.x + sprite.width * IMAGE_ZOOM then
          if y >= sprite.y && y <= sprite.y + sprite.height * IMAGE_ZOOM then
              within_img_range = true
              selected_id = count
              break
          end
        end

        count = count + 1
      end
    end

    if Input.repeat?(:C) && within_img_range == true
      if @get_type == 0 then
          $game_switches[ADDITION_SWITCH_STORE + @display_images_switches[selected_id]] = true
          upload_image
          calc_patreon_increase(0)
          dispose_current_images
          get_possible_images
      elsif @get_type == 1 then
          $game_switches[ADDITION_SWITCH_STORE + @display_images_switches[selected_id]] = true
          upload_image
          calc_patreon_increase(1)
          dispose_current_images
          get_possible_images
      elsif @get_type == 2 then
          return
      elsif @get_type == 3 then
          $game_variables[BACKGROUND_IMG_VAR] = get_img_name(@display_images_switches[selected_id])
          puts $game_variables[BACKGROUND_IMG_VAR]
      end

    end
  end
  
  def exe_action_home(action_id)
    case action_id
    when 0 # Home
      clear_scene
      @current_screen = 0
      draw_scene
    when 1 # new post
      clear_scene
      @current_screen = 1
      draw_scene
    when 2 #edit banner
      clear_scene
      @current_screen = 2
      draw_scene
    else
      return
    end
    
  end
  
  def exe_action_new(action_id)
    case action_id
    when 0 # Home
      clear_scene
      @current_screen = 0
      draw_scene
    when 1 # new post
      clear_scene
      @current_screen = 1
      draw_scene
    when 2 #new text
      FeedbackMsg.display_feedback("No one cares.")
    when 3 #new image
      @get_type = 0
      get_possible_images
    when 4 # new vid
      @get_type = 1
      get_possible_images
      return  
    else
      return
    end
    
  end
  
  def exe_action_ban(action_id)
    case action_id
    when 0 # Home
      clear_scene
      @current_screen = 0
      draw_scene
    when 1 # new post
      clear_scene
      @current_screen = 1
      draw_scene
    when 2 #new text
      FeedbackMsg.display_feedback("No one cares.")
      return
      @get_type = 2
      get_possible_images
    when 3 #new image
      @get_type = 3
      get_possible_images
    else
      return
    end
    
  end

  def place_icon(name,x,y)
      new_icon = Sprite.new
      new_icon.bitmap = Cache.paymeon(name)
      new_icon.x = x
      new_icon.y = y
      new_icon.z = 5
      
      @icons.push new_icon    
  end
    
  def calc_patreon_increase(type)
    case type
    when 0 then
      inc = @rand.rand(3..7)
      $game_variables[DOLLAR1_INCREASE_VAR] += inc
      puts "Added " + inc.to_s + " to $1 Pledgers. Toal:" + $game_variables[DOLLAR1_INCREASE_VAR].to_s 
    when 1 then
      inc = @rand.rand(2..5)
      $game_variables[DOLLAR5_INCREASE_VAR] += inc
      puts "Added " + inc.to_s + " to $5 Pledgers. Toal:" + $game_variables[DOLLAR5_INCREASE_VAR].to_s 
    else
      return
    end
  end
    
  
  def upload_image
    width = 400
    height = 100
    x = Graphics.width / 2 - width / 2
    y = Graphics.height / 2 - height / 2
    
    @uploading = true
    
    @max_count = 100.to_f
    @current_count = 0.to_f

    @upload = Window_Base.new(x, y, width, height)
    
    @upload.draw_text_ex_extra(0,0,"Uploading...",0)
    
    @upload.draw_gauge(0,20,width,@current_count/@max_count,@upload.text_color(27),@upload.text_color(30))
    
  end
  
  def update_upload
    if @uploading == false then
      return
    end
    
    width = 400
    height = 100
    x = Graphics.width / 2 - width / 2
    y = Graphics.height / 2 - height / 2
    
    @current_count = @current_count + 1
    @upload.draw_gauge(0,20,width,@current_count/@max_count,@upload.text_color(27),@upload.text_color(30))
    
    if @current_count >= @max_count then
      @uploading = false
      RPG::SE.new("Item1",100,100).play
      puts "disposing"
      @upload.close if @upload
    end
  end
    
  def get_possible_images #type-d = 0 = Upload Image, 1 = Upload Video, 2 = Pick Banner (group), 3 = Pick Banner (single)    
      @display_images = []
      @display_images_switches = []
      
      count = 1

      start_x = 250
      x = start_x
      y = 350
      
      zoom = IMAGE_ZOOM
      
      gallery = CRM_Gallery::Gallery
      switch_start = PHOTO_SWITCH_ID_START
      max_check = switch_start + MAX_TO_CHECK
             
      for i in switch_start..max_check
        
        if $game_switches[i] == false || ($game_switches[ADDITION_SWITCH_STORE + i] == true && @get_type == 0 || @get_type == 1) then
          next
        end
        
        if @get_type == 3 && SOLO_IMGS_SWITCHES.include?(i) then
          next
        end

        record = gallery.key(i)
        
        puts record
        
        new_img = Sprite.new
        new_img.bitmap = Cache.gallery(record)
        new_img.x = x
        new_img.y = y
        new_img.z = 10
        new_img.zoom_x = zoom
        new_img.zoom_y = zoom
        
        @display_images.push new_img
        @display_images_switches.push i
        
        if count >= GRID_WIDTH then       
          x = start_x
          y = y + new_img.height  * zoom
          count = 1
        else
          x = x + new_img.width * zoom
          count = count + 1
        end
        
        if @display_images.count == MAX_TO_SHOW
          break
        end
      end
      if @display_images.count == 0 then
        FeedbackMsg.display_feedback("No Images to Upload.")
      end
        
      @disposed = false
      
    end
  
    def get_img_name(switch)
      gallery = CRM_Gallery::Gallery
      return gallery.key(switch)      
    end
    

    def dispose_current_icons
      @disposed = true
      @icons.each do | sprite |
        sprite.bitmap.dispose
        sprite.dispose
      end 
      @icons = []
    end
    
    def dispose_current_images
      @disposed = true
      @display_images.each do | sprite |
        sprite.bitmap.dispose
        sprite.dispose
      end 
      @display_images = []
    end
  
  
    def clear_scene
      @bio.close if @bio
      @title.close if @title
      @pledgers.close if @pledgers
      @reward.close if @reward
      dispose_current_icons
      dispose_current_images
      
    end
end