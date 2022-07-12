
class Hash

  def replace_keys(defaults)
    new_hash = self
    defaults.each do |find,replace|
      new_hash = new_hash.transform_keys{|k| k == find ? replace : k}
    end
    return(new_hash)
  end

end
