
class Array

  def replace_keys(defaults)
    new_a = []
    self.each do |v|
      if v.class == Array
        new_a << v.replace_keys(defaults)
      elsif v.class == Hash
        new_h = v
        defaults.each do |find,replace|
          # logger.debug "#{find} => #{replace}"
          # logger.debug "v:#{v}"
          new_h = new_h.transform_keys{|k| k == find ? replace : k}
        end
        new_a << new_h
      else
        new_a << v
      end
    end
    return(new_a)
  end

  def deep_symbolize_keys!
    self.map{|h| h.deep_symbolize_keys!}
  end

end
