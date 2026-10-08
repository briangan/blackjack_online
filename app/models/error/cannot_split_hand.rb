module Error
  class CannotSplitHand < ArgumentError
    def initialize(msg = nil)
      super( ["Cannot split this hand", msg].reject(&:blank?).join(', ') )
    end
  end
end