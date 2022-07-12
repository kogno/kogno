class String

  def to_payload
    self.downcase.gsub(" ","_").to_sym
  end
end