class Game < ApplicationRecord
  VALID_STATUSES = %[WAITING IN_PROGRESS COMPLETED CANCELLED]
  COUNT_OF_DECKS_PER_GAME = 1

  belongs_to :dealer, class_name:'Dealer', foreign_key:'dealer_id', optional: true

  has_many :play_cards, dependent: :destroy
  has_many :available_play_cards, -> { where("given_user_id IS NULL")}, class_name:'PlayCard'
  has_many :hands, dependent: :destroy

  before_save :set_defaults
  after_create :generate_initial_records!

  def dealer_hand
    self.hands.find_or_create_by(user_id: dealer_id)
  end

  ###################################
  # Main actions

  # Find or create user.  Then create an new empty hand given bet amount, which means a user can have multiple hands.
  # @return <Hand> either found or created hand
  def add_hand_for_user!(name_or_user, bet_amount)
    raise ArgumentError.new("Need to provide the name of user") if name_or_user.nil? || (name_or_user.is_a?(String) && name_or_user.strip.blank? )

    user = name_or_user.is_a?(User) ? name_or_user : User.find_or_create_by(name: name_or_user.strip)

    unless user.is_a?(Dealer)
      raise Error::InvalidBetAmountError.new if bet_amount.to_f <= 0.0

      raise Error::OutOfBalanceError.new if user.balance.to_f <= bet_amount
    end

    self.hands.create(user_id: user.id, total_bet_amount: bet_amount)
  end

  def start_game!
    initial_pass_cards_to_all!
  end

  ##################################
  # Helper methods

  protected

  def generate_initial_records!
    generate_play_cards!
    dealer_hand
  end

  def initial_pass_cards_to_all!
  a_play_cards = available_play_cards.order(:order_index).limit(hands.count * 2).all
  index = 0
  # starts w/ dealer
  hands.each do|hand|
    1.upto(2) do
      a_play_cards[index].pass_to!(hand.user_id)
      index += 1
    end
  end
end

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
          PlayCard.create(game_id: self.id, rank: rank, suit: suit, order_index: shuffled_order_indices.pop)
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
