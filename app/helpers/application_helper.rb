module ApplicationHelper
  # Format a numeric answer cleanly: strip trailing zeros but keep precision
  def format_answer(value)
    f = value.to_f
    if f == f.to_i
      f.to_i.to_s
    else
      # Remove unnecessary trailing zeros
      f.to_s.sub(/\.?0+$/, "")
    end
  end
end
