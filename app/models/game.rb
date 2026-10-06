class Game < ApplicationRecord
  VALID_STATUSES = %[WAITING IN_PROGRESS COMPLETED CANCELLED]
  COUNT_OF_DECKS_PER_GAME = 1

  belongs_to :dealer, class_name:'Dealer', foreign_key:'dealer_id', optional: true

  has_many :play_cards, dependent: :destroy
  has_many :hands, dependent: :destroy

  before_save :set_defaults
  after_create :generate_play_cards!

  protected

  # Dependent on COUNT_OF_DECKS_PER_GAME
  def generate_play_cards!
    shuffled_order_indices = []
    1.upto(COUNT_OF_DECKS_PER_GAME * Card::RANKS.size * Card::SUITS.size) do|i|
      shuffled_order_indices << i
    end
    shuffled_order_indices.shuffle!

    1.upto(COUNT_OF_DECKS_PER_GAME) do|deck_i|
      Card::RANKS.each do|rank|
        Card::SUITS.each do|suit|
          PlayCard.create(game_id: self.id, rank: rank, suit: suit)
        end
      end
    end
  end

  private

  def set_defaults
    self.status = 'WAITING' if status.blank?
    self.dealer_id ||= Dealer.default_dealer.id
  end
end
