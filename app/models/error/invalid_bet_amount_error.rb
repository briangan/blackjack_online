module Error
  class InvalidBetAmountError < ArgumentError
    def initialize(msg = '')
      super( ["Need to provide bet amount", msg].reject(&:blank?).join('. ') )
    end
  end
end