# Columns: game_id user_id order_index total_bet_amount status
class Hand < ApplicationRecord

  STATUSES = %w(NEW STAND WIN LOSE TIE)
  STATUSES.each do |status|
    unless respond_to?("#{status.downcase}?")
      define_method("#{status.downcase}?") do
        self.status&.upcase == status
      end
    end
  end

  belongs_to :game, dependent: :destroy
  belongs_to :user, dependent: :destroy
  alias_method :player, :user

  has_many :play_cards
  has_many :play_actions, class_name:'PlayAction::PlayAction'

  before_create :set_initial_attributes

  # Variations of values caused by A.
  def variants_of_total_value
    generate_combos( play_cards.collect{|pc| pc.card.values } ).collect do|combo|
      combo.flatten.sum
    end.flatten
  end

  # The max value that is not busted
  def best_total_value
    variants_of_total_value.reject{|total| total > 21 }.max
  end

  # Recursive generation of all combos when given an Array with each element being sub-array of possible values.
  # For example,
  #   generate_combos [ [1, 11], [2], [3] ]
  #   should output
  #     [ [[1], [2], [3]],
  #       [[11]], [2], [3]] ]
  def generate_combos(choices, current_combo = [])
    return [current_combo] if choices.empty?

    # Take first ... then rest
    head, *tail = choices
    
    results = []
    head.each do |value|
      # append each of the head as new combo
      new_combo = current_combo + [[value]]
      
      # Recursively generate combos for the tail
      results.concat( generate_combos(tail, new_combo) )
    end
    
    results
  end

  # All variants are busted
  def busted?
    variants_of_total_value.all?{|total| total > 21 }
  end

  def to_s
    "Hand for #{user.name} (#{user.type}) w/ $#{total_bet_amount}, values #{variants_of_total_value.inspect}, cards: #{play_cards.collect{|pc| pc.card.to_s }.join(", ")}"
  end

  def check_for_ending_status
    if busted?
      self.update(status: 'LOSE')
    end
  end
  
  # Really must be exactly 2 of same rank cards, or can be more than 3 also?
  def can_split_now?
    play_cards.count >= 2 && play_cards.collect{|pc| pc.card.values.min }.uniq.size == 1
  end

  #######################
  # Actions for player to choose

  # @return <Card>
  def hit!
    next_play_card = game.available_play_cards.first
    next_play_card.pass_to!(self.id)
    
    ::PlayAction::Hit.create(hand_id: self.id)

    self.reload # ensure all attributes and associations fresh

    check_for_ending_status

    next_play_card
  end

  def stand!
    self.update(status: 'STAND')
    ::PlayAction::Stand.create(hand_id: self.id)
  end
  alias_method :stay!, :stand!

  # Double the bet, take one final card, then stand.
  # @return <Card>
  def double!
    next_play_card = game.available_play_cards.first
    next_play_card.pass_to!(self.id)
    
    ::PlayAction::Double.create(hand_id: self.id, amount: self.total_bet_amount)

    self.reload # ensure all attributes and associations fresh

    check_for_ending_status

    next_play_card
  end

  # If a player have a pair of same, split into two hands by placing a second bet equal to first bet, and 
  # get another card.
  # @return <Hand> new hand created
  def split!
    raise ::Error::CannotSplitHand.new unless can_split_now? 

    another_hand = Hand.create(game_id: game_id, user_id: user_id, order_index: order_index, total_bet_amount: total_bet_amount)
    self.play_cards[1].pass_to!(another_hand.id)

    ::PlayAction::Split.create(hand_id: self.id, amount: self.total_bet_amount)

    # Fill w/ new card each
    next_play_cards = game.available_play_cards.limit(2).to_a
    next_play_cards[0].pass_to!(self.id)

    next_play_cards[1].pass_to!(another_hand.id)

    self.reload # Ensure self and associations fresh

    another_hand
  end

  private

  def set_initial_attributes
    self.order_index = Hand.where(game_id: game_id).count + 1
    self.status = 'NEW'
  end
end
