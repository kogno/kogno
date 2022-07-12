module Kogno

  class BaseConfig 

    def initialize(*attr_accessors)
      attr_accessors.each do |attr_accessor_name|
        self.class.send(:attr_accessor, attr_accessor_name)
      end
    end

    def to_h
      self.as_json
    end

  end
  
end