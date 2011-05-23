module EntriesHelper
  def pretty_date(date)
    return "#{Date::ABBR_DAYNAMES[date.wday]} #{date.strftime("%x")}" 
  end
end
