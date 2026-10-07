module Error
  class OutOfBalanceError < ArgumentError
    def initialize(msg = nil)
      super(msg || "User account balance is out")
    end
  end
end