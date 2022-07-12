module Kogno
class Spelling

  class << self

    def correction(sentece) # Este metodo deberia ser sobrescrito en app/extensions si hay que agregar corrector ortografico antes del pasarle al wit
      sentece
    end

  end

end
end
