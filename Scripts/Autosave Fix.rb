module DataManager
 
 class << self
   alias_method(:ms_fear_fix_original_save_game_without_rescue,
                :save_game_without_rescue)
                
   def save_game_without_rescue(index)
     scene = SceneManager.scene
     scene.dispose_lights if scene.is_a?(Scene_Map)
     result = ms_fear_fix_original_save_game_without_rescue(index)
     scene.setup_lights if scene.is_a?(Scene_Map)
     return result
   end
   
 end
 
end

class Scene_Map
 def dispose_lights; @spriteset.dispose_lights; end
 def setup_lights; @spriteset.setup_lights; end
end