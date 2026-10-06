class Card
  RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K]
  RANKS_OF_10_VALUE = %w[J Q K]
  SUITS = %w(diamond club heart spade)

  attr_reader :rank, :suit

  def initialize(rank, suit)
    self.rank = rank.upcase
    self.suit = suit.titleize
  end

  # Card like A can have multiple values [1, 11]
  def values
    if rank == 'A'
      [1, 11]
    elsif RANKS_OF_10_VALUE.include?(rank)
      10
    else
      rank.to_i
    end
  end

  # There can be multiple-value card like A (1, 11)
  def max_value
    values.max
  end

  def title
    "#{rank} of #{suit}"
  end
end