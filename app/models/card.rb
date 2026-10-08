class Card
  RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K]
  RANKS_OF_10_VALUE = %w[10 J Q K]
  RANKS_OF_LESS_THAN_10 = %w[A 2 3 4 5 6 7 8 9]
  SUITS = %w(diamond club heart spade)

  attr_reader :rank, :suit

  # @return <String>
  def self.find_rank_with_value(value, should_be_random = false)
    if value == 11 || value == 1
      'A'
    elsif value == 10
      should_be_random ? RANKS_OF_10_VALUE[ rand(RANKS_OF_10_VALUE.size - 1) ] : RANKS_OF_10_VALUE[0]
    else
      value.to_s
    end
  end

  def initialize(rank, suit)
    @rank = rank.upcase
    @suit = suit.titleize
  end

  # Card like A can have multiple values [1, 11]
  def values
    if rank == 'A'
      [1, 11]
    elsif RANKS_OF_10_VALUE.include?(rank)
      [10]
    else
      [rank.to_i]
    end
  end

  def min_value
    values.min
  end

  # There can be multiple-value card like A (1, 11)
  def max_value
    values.max
  end

  def to_s
    "Card[#{rank} of #{suit}]"
  end
end