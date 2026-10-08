module Error
  class OutOfBalanceError < ArgumentError
    def initialize(msg = '')
      super( ["User account balance is out", msg].reject(&:blank?).join('. ') )
    end
  end
end