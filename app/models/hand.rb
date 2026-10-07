
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
