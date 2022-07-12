def tabulate(text, divider, max_chars, orientation = "left")
  amount = text.count(divider)
  amount = amount + 1
  spacing = max_chars / amount
  text = text.split(divider)
  text.each do |str|
    str = str.strip
    index = text.find_index(str)
    if str[0] == " "
      text[index] = str[1..-1]
    elsif str[str.length - 1] == " "
      text[index] = str.chop
    end
  end
  new_text = []
  #even_space = 0

  case orientation
  when "left"
    new_text = tabulateLeft(text, spacing)
  when "right"
    new_text = tabulateRight(text, spacing)
  when "middle"
    new_text = tabulateMiddle(text, spacing)
  end

  return new_text.join(divider)
end

def tabulateLeft(text, spacing)
  new_text = []
  text.each do |str|
    tab_str = str
    spaces = spacing - str.length

    if text.find_index(tab_str).even?
      if spacing > tab_str.length && text.find_index(tab_str) != 0
        tab_str.prepend(" ")
        spaces -= 1
      end
      while spaces > 0 do
        tab_str.concat(" ")
        spaces -= 1
      end
    else
      if spacing > tab_str.length
        tab_str.prepend(" ")
        spaces -= 1
      end
      while spaces > 0 do
        tab_str.concat(" ")
        spaces -= 1
      end
    end
    new_text << tab_str
  end
  return new_text
end

def tabulateRight(text, spacing)
  new_text = []
  text.each do |str|
    tab_str = str
    spaces = spacing - str.length

    if text.find_index(tab_str).even?
      if spacing > tab_str.length
        tab_str.concat(" ")
        spaces -= 1
      end
      while spaces > 0 do
        tab_str.prepend(" ")
        spaces -= 1
      end
    else
      while spaces > 0 do
        tab_str.prepend(" ")
        spaces -= 1
      end
    end
    new_text << tab_str
  end
  return new_text
end

def tabulateMiddle(text, spacing)
  new_text = []
  text.each do |str|
    tab_str = str
    spaces = spacing - str.length
    divided = spaces / 2
    concat = false

    while spaces > divided do
      tab_str.prepend(" ")
      spaces -= 1
    end
    while spaces > 0 do
      tab_str.concat(" ")
      spaces -= 1
    end
    new_text << tab_str
  end
  return new_text
end