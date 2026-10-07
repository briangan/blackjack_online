module Error
  class InvalidBetAmountError < ArgumentError
    def initialize(msg = nil)
      super(msg || "Need to provide bet amount")
    end
  end
end