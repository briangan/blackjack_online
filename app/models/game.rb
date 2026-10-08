# Columns: started_at status dealer_id
class Game < ApplicationRecord
  VALID_STATUSES = %[WAITING IN_PROGRESS COMPLETED CANCELLED]
  COUNT_OF_DECKS_PER_GAME = 1

  belongs_to :dealer, class_name:'Dealer', foreign_key:'dealer_id', optional: true

  has_many :play_cards, dependent: :destroy
  has_many :available_play_cards, -> { where("hand_id IS NULL").order('order_index asc') }, class_name:'PlayCard'
  has_many :hands, dependent: :destroy

  before_save :set_defaults
  after_create :generate_initial_records!

  def dealer_hand
    dh = self.hands.find_or_initialize_by(user_id: dealer_id)
    dh.save
    dh
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

      raise Error::InsufficientBalanceForBetAmount.new if user.balance.to_f <= bet_amount
    end

    self.hands.create(user_id: user.id, total_bet_amount: bet_amount)
  end

  def start_game!
    self.update(started_at: Time.now)
    initial_pass_cards_to_all!
  end

  ##
  # Compare dealer hand vs player hands, set status, and return amount to user if needed.
  # The dealer's hand needs to finish also.
  # @yield <Hand> w/ status update
  def analyze_hands!(&block)
    raise Error::DealerNotFinished.new unless dealer_hand.is_turn_ended?
    
    dealer_best_value = dealer_hand.best_total_value

    self.hands.each do|hand|
      next if hand.user_id == dealer_id
      
      unless hand.lose? # already lost, no money return

        if dealer_hand.lose? && hand.lose? || dealer_best_value == hand.best_total_value
          hand.status = 'TIE'
          hand.save
          hand.return_amount_to_user!

        elsif dealer_hand.lose? || dealer_best_value < hand.best_total_value
          hand.status = 'WIN'
          hand.save
          hand.return_amount_to_user!

        else
          hand.status = 'LOSE'
          hand.save
        end
      end
      yield hand if block_given?
    end
    self.hands.reload
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
      a_play_cards[index].pass_to!(hand.id)
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
          PlayCard.create(game_id: self.id, rank: rank, suit: suit, order_index: shuffled_order_indices.shift)
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
