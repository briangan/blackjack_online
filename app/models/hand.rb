
class Hand < ApplicationRecord

  STATUSES = %w(NEW WIN LOSE TIE)
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
  has_many :play_actions

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


  #######################
  # Actions

  def hit!
    # TODO: Implement
  end

  def stand!
    # TODO: Implement
  end
  alias_method :stay!, :stand!

  # Double the bet, take one final card, then stand.
  def double!
    # TODO: Implement
  end

  # If a player have a pair of same, split into two hands by placing a second bet equal to first bet.
  # @return <Hand> new hand created
  def split!
    # TODO: Implement
  end

  private

  def set_initial_attributes
    self.order_index = Hand.where(game_id: game_id).count + 1
    self.status = 'NEW'
  end
end
