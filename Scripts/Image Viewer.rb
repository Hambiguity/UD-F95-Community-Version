#==================================================================
# CRM Art Gallery
# Author: Raizen
# Comuninity : http://centrorpg.com/
# Compatibility: RMVXA
#==================================================================

# Instructions:

# Really easy and simple to use and modify, to modify the images,
# Go to Graphics/Gallery inside your project folder and trade the images 
# inside, with images of the same name.
# In case you have erased any of the images, here is a relation of
# the images' name needed.

# To call the art gallery.
# Script Call: SceneManager.call(Scene_CRM_Gallery)

=begin
Image Names

=> superior
=> superior2
=> ArrowDown
=> ArrowLeft
=> ArrowUp
=> ArrowRight
=> background


=end

#====================================================================

# Here you configure the script according to the images you wish.

module CRM_Gallery
  
  
# Put the images' name inside "" in the order you wish to appear in the gallery,
# with the switch you want to use to unlock the image.

# You can use any size of Image, they are automatically resized to fit the screen.

# Following this pattern, 

# 'Image Name' => Switch number.

Gallery = {
'MomPic1' => 201 ,
'MomPic2' => 202 ,
'MomPic3' => 203 ,
'SydneyPic1' => 204,
'SydneyPic2' => 205,
'SydneyPic3' => 206,
'MrsJenningsPic1' => 207,
'MrsJenningsPic2' => 208,
'MrsJenningsPic3' => 209,
'SydneyPic4' => 210,
'SarahPic1' => 211,
'SarahPic2' => 212,
'SarahLisaPic1' => 213,
'KimberlyPic1' => 214,
'MrsJenningsPic2P' => 215,
'MomSleepingPic' => 216,
'KayleePic1' => 217,
'MomShowerPic' => 218,
'MrsJenningsPic4' => 219,
'DonnaPic1' => 220,
'DonnaPic2' => 221,
'DizzyPic1' => 222,
'MrsJSend' => 223,
}


# Here the cursor position for image moving.
# X
Cur_X = 1000
# Y
Cur_Y = 500

# Time it will take in frames to erase the cursors and superior image.
# (60 frames = 1 second)
Time = 200

Standard_Z = 10


# Add the gallery to the default Menu?
# (false if true is not compatible with the menu being used)

Add = true

# Name on the Menu

Name = "Gallery"
# =============================================================================
# =========================Here starts the script===============================
# =============================================================================

end
#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  Este modulo carrega cada gráfico, cria um objeto de Bitmap e retém ele.
# Para acelerar o carregamento e preservar memória, este módulo matém o
# objeto de Bitmap em uma Hash interna, permitindo que retorne objetos
# pré-existentes quando mesmo Bitmap é requerido novamente.
#==============================================================================


module Cache
  #--------------------------------------------------------------------------
  # * Carregamento dos gráficos de animação
  #     filename : nome do arquivo
  #     hue      : informações da alteração de tonalidade
  #--------------------------------------------------------------------------
  def self.gallery(filename)
    load_bitmap("Graphics/Gallery/", filename)
  end
end


class Game_Interpreter
  def add_pic(switch)
    $game_switches[switch] = true
    CustomGab.display_message("New Image")
  end
end


#==============================================================================
# ** Scene_CRM_Gallery
#------------------------------------------------------------------------------
#  Esta classe executa a preview das imagens
#==============================================================================

class Scene_CRM_Gallery < Scene_Base
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  # * Carregamento de Imagens (pode demorar caso tenha muitas imagens)
  #--------------------------------------------------------------------------
  def start
    super
    #@background = Sprite.new
    #@background.bitmap = Cache.gallery("background")
    #@front = Sprite.new
    #@front.bitmap = Cache.gallery("superior")
    #@front.z = 20
    @gallery = Array.new
    @gallery_pic = Array.new
    @number = Array.new
    @current_gallery = CRM_Gallery::Gallery
    @current_gallery = @current_gallery.flatten.rotate!($current_pic*2)
    until @gallery.size > 6
      for n in 0...@current_gallery.size/2
        @gallery.push(@current_gallery[n*2]) if $game_switches[@current_gallery[(n*2)+1]]
        n += 1
      end
      if @gallery.size == 0
        terminate
        return_scene
        return
      end
    end
    for n in 0...@gallery.size
      @number[n] = n
      @gallery_pic[n] = Sprite.new
      @gallery_pic[n].bitmap = Cache.gallery(@gallery[n])
      @gallery_pic[n].x = 130*n + 20 
      @gallery_pic[n].y = (Graphics.height / 4) * 3
      @gallery_pic[n].z = CRM_Gallery::Standard_Z + n
      @gallery_pic[n].zoom_x = 0.25
      @gallery_pic[n].zoom_y = 0.25
    end
    @preview = Sprite.new
    @preview.bitmap = Cache.gallery(@gallery[3])
    @preview.x = 0
    @preview.y = 0
    
    @arrowup = Sprite.new
    @arrowup.bitmap = Cache.gallery("ArrowUp")
    
    y = @gallery_pic[@number[3]].y - (@arrowup.height / 2)
    z = CRM_Gallery::Standard_Z + 10
    

    @arrowup.x = @gallery_pic[@number[3]].x + (@gallery_pic[@number[3]].width / 8) - (@arrowup.width / 2)
    @arrowup.y = y
    @arrowup.z = z
    
    @arrowleft = Sprite.new
    @arrowleft.bitmap = Cache.gallery("ArrowLeft")
    @arrowleft.x = 20
    @arrowleft.y = y
    @arrowleft.z = z
    
    @arrowright = Sprite.new
    @arrowright.bitmap = Cache.gallery("ArrowRight")
    @arrowright.x = Graphics.width - 20 - @arrowright.width 
    @arrowright.y = y
    @arrowright.z = z
    
  end
  #--------------------------------------------------------------------------
  # * finalização do processo
  #--------------------------------------------------------------------------
  def terminate
    super
    @gallery_pic.each {|gallery| gallery.bitmap.dispose ; gallery.dispose}

    @arrowup.bitmap.dispose if @arrowup
    @arrowup.dispose if @arrowup
    
    @arrowleft.bitmap.dispose if @arrowleft
    @arrowleft.dispose if @arrowleft
    
    @arrowright.bitmap.dispose if @arrowright
    @arrowright.dispose if @arrowright
    
  
    if @preview
    @preview.bitmap.dispose 
    @preview.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    for n in 0...@gallery_pic.size
      if n > 0 && n < @gallery_pic.size - 1
        if @gallery_pic[@number[n]].x > 130 * n + 20
          @gallery_pic[@number[n]].x -= 13
        elsif @gallery_pic[@number[n]].x < 130 * n +20 
          @gallery_pic[@number[n]].x += 13
        end
      else
        @gallery_pic[@number[n]].x = 130 * n + 20 
      end
      bottom_placement = (Graphics.height / 4) * 3
      max_y = bottom_placement - ((@gallery_pic[@number[n]].height / 4) / 4)
      if n == 3
        @gallery_pic[@number[n]].y -= 4 if @gallery_pic[@number[n]].y > max_y  
        @gallery_pic[@number[n]].z = CRM_Gallery::Standard_Z + 10
      else
        @gallery_pic[@number[n]].y += 4 if @gallery_pic[@number[n]].y < bottom_placement        
      end
      if n > 3 then 
        @gallery_pic[@number[n]].z = CRM_Gallery::Standard_Z + (10 - n)
      elsif n < 3 then
        @gallery_pic[@number[n]].z = CRM_Gallery::Standard_Z + n
      end
      
    end
    return_scene && Sound.play_cancel if Input.trigger?(:B)
    if Input.trigger?(:RIGHT)
      @number.rotate!(1)
      Sound.play_cursor
      @preview.bitmap = Cache.gallery(@gallery[@number[3]])
    end
    if Input.trigger?(:LEFT)
      @number.rotate!(-1) 
      Sound.play_cursor
      @preview.bitmap = Cache.gallery(@gallery[@number[3]])
    end
    if Input.trigger?(:UP)
      $gallery_crm_pic = @gallery[@number[3]]
      $current_pic = @number.first
      SceneManager.call(Scene_Show_Gal)
    end
  end
end

#==============================================================================
# ** Scene_Show_Gal
#------------------------------------------------------------------------------
#  Esta classe executa a imagem após a escolha
#==============================================================================

  #--------------------------------------------------------------------------
  # * Inicialização do processo
  # * Carregamento de Imagens (pode demorar caso seja muito grande a imagem)
  #--------------------------------------------------------------------------
  
class Scene_Show_Gal < Scene_Base
  def start
    super
    @pic = Sprite.new
    @pic.bitmap = Cache.gallery($gallery_crm_pic)
    @pic.x = Graphics.width/2 - @pic.width/2
    @pic.y = Graphics.height/2 - @pic.height/2
    @all_zoom = false
    
    
    @arrowdown = Sprite.new
    @arrowdown.bitmap = Cache.gallery("ArrowDown")
    @arrowdown.x = (Graphics.width/2) - (@arrowdown.width / 2)
    @arrowdown.y = Graphics.height - 20 - @arrowdown.height
    @arrowdown.z = CRM_Gallery::Standard_Z + 10

    update
  end
  
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  def update
    super
    
    if Input.press?(:DOWN) 
      return_scene
    end
  end
  #--------------------------------------------------------------------------
  # * Finalizando o processo
  #--------------------------------------------------------------------------
  def terminate
    super
    @pic.bitmap.dispose
    @pic.dispose
    @arrowdown.bitmap.dispose
    @arrowdown.dispose
  end
end

if CRM_Gallery::Add
#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  Esta classe executa o processamento da tela de menu.
#==============================================================================

class Scene_Menu < Scene_MenuBase
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:skill,     method(:command_personal))
    @command_window.set_handler(:equip,     method(:command_personal))
    @command_window.set_handler(:status,    method(:command_personal))
    @command_window.set_handler(:gallery,  method(:command_gallery))
    @command_window.set_handler(:formation, method(:command_formation))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end
  def command_gallery
    SceneManager.call(Scene_CRM_Gallery)
  end
end
$current_pic = 0
#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  Esta janela exibe os comandos do menu.
#==============================================================================
class Window_MenuCommand < Window_Command
alias raizen_add_main_commands add_main_commands
  def add_main_commands
    raizen_add_main_commands
    add_command(CRM_Gallery::Name, :gallery, main_commands_enabled)
  end
end
end