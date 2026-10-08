module Error
  class DealerNotFinished < ArgumentError
    def initialize(msg = '')
      super( ["The dealer is not finished with moves yet", msg].reject(&:blank?).join('. ') )
    end
  end
end