module PeirEmissionsHelper
  def habit_to_s(id)
    case PeirEmission.find(id).habit
    when 1
      s = "daily"
    when 2
      s= "every weekday"
    when 3
      s = "once a week"
    end
    s
  end
end