class InvalidBetAmount < ArgumentError
  def initialize(msg = nil)
    super(msg || "Need to provide bet amount")
  end
end

class OutOfBalance < ArgumentError
  def initialize(msg = nil)
    super(msg || "User account balance is out")
  end
end