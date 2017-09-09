class FreeText_Handler

  def self.convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    #result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eN\[(\d+)\]/i) { $game_actors[$1.to_i].name }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    return result
  end
  
end