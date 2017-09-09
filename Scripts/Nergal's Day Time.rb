module Day_Time
  #Array must match number of days in week
  PERIODS_OF_DAY_NAMES = ["Morning", "Midday", "Afternoon", "Evening", "Night"]
  
  PERIOD_TIMES = ["08:00","12:30","16:00","19:30","00:00"]

  #Array must match number of days in week
  DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
 
  #Array must match number of months
  MONTHS_OF_YEAR = ["January","February","March","April","May","June",
              "July","August","September","October","November","December"]
              
              
              
  DAYS_OF_MONTHS = [31,28,31,30,31,30,31,31,30,31,30,31]
  
              
  TIME_OF_DAY_VAR = 2
  DAY_VAR = 3
  DATE_VAR = 4
  MONTH_VAR = 5
  YEAR_VAR = 6
  
  PERIOD_CHANGE_COMMON_EVENT = 26 #This common even will run whenever the period of day changes
  DAY_CHANGE_COMMON_EVENT = 27 #This common event will run whenever the day changes 
  MONTH_CHANGE_COMMON_EVENT = 28 #This common event will run whenever the month changes
  YEAR_CHANGE_COMMON_EVENT = 29 #This common event will run whenevr the year changes
  

  NO_OF_PERIODS = PERIODS_OF_DAY_NAMES.count - 1
  DAYS_PER_WEEK = DAY_NAMES.count - 1
  MONTHS_IN_YEAR = MONTHS_OF_YEAR.count - 1
  
  
  def self.advance_day
    if $game_variables[TIME_OF_DAY_VAR] == NO_OF_PERIODS then
      $game_variables[TIME_OF_DAY_VAR] = 0
      increase_date
    else
      $game_variables[TIME_OF_DAY_VAR] += 1  
      $game_temp.reserve_common_event(PERIOD_CHANGE_COMMON_EVENT) 
    end
  end
  
  
  def self.increase_date      
    if $game_variables[DAY_VAR] == DAYS_PER_WEEK then
      $game_variables[DAY_VAR] = 0
    else
      $game_variables[DAY_VAR] += 1
    end

    if $game_variables[DATE_VAR] == DAYS_OF_MONTHS[$game_variables[MONTH_VAR]] then
       $game_variables[DATE_VAR] = 1 # There is no "0th June" for example
       increase_month
    else
       $game_variables[DATE_VAR] += 1   
       $game_temp.reserve_common_event(DAY_CHANGE_COMMON_EVENT)
     end
   end
      
  
  def self.increase_month
    if $game_variables[MONTH_VAR] == MONTHS_IN_YEAR then
      $game_variables[MONTH_VAR] = 0
      increase_year
    else
      $game_variables[MONTH_VAR] += 1
      $game_temp.reserve_common_event(MONTH_CHANGE_COMMON_EVENT)
    end
    
  end
  
  def self.increase_year
    $game_variables[YEAR_VAR] += 1 
    $game_temp.reserve_common_event(YEAR_CHANGE_COMMON_EVENT)
  end
   
    
  
  def self.get_current_time_period
    return get_time_period($game_variables[TIME_OF_DAY_VAR])
  end
  
  def self.get_time_period(period)
    return PERIODS_OF_DAY_NAMES[period]
  end
    
  def self.get_current_day_name
    return get_day_name($game_variables[DAY_VAR])
  end
  
  def self.get_day_name(day)
      return DAY_NAMES[day]
  end
    
  def self.get_current_month_name
    return get_month_name($game_variables[MONTH_VAR])
  end
  
  def self.get_month_name(month)
      return MONTHS_OF_YEAR[month]
  end
   
  def self.get_current_date_full
    period = get_current_time_period
    day = get_current_day_name
    date = $game_variables[DATE_VAR].to_s
    month = get_current_month_name
    year = $game_variables[YEAR_VAR].to_s
    
    return period + ": " + day + " " + date + " " + month + " " + year
  end
  
  def self.get_phone_time
    return PERIOD_TIMES[$game_variables[TIME_OF_DAY_VAR]]
  end
  
  def self.get_phone_date
    day_char = (get_current_day_name)[0...3]
    date = $game_variables[DATE_VAR].to_s
    month = (get_current_month_name)[0...3]
    
    return day_char + " " + date + " " + month.upcase
    
  end
  
  def self.get_current_date
    period = get_current_time_period
    day = get_current_day_name[0,3]
    date = $game_variables[DATE_VAR].to_s
    month = get_current_month_name[0,3]
    
    return period + ": " + day + " " + date + " " + month
  end

end    
  
    