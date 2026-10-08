module Error
  class InsufficientBalanceForBetAmount < ArgumentError

    # Not sure if there's decimal (less than dollar coins) in balance
    def initialize(balance = nil, bet_amount = nil, msg = '')
      warning_msg = "The player's balance%s is insufficent for bet%s" % [
          balance ? ' $' + balance.to_i.to_s : '',
          bet_amount ? ' amount $' + bet_amount.to_i.to_s : ''
        ]
      super( [warning_msg, msg].reject(&:blank?).join('. ') )
    end
  end
end