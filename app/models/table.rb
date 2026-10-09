class Table < ApplicationRecord
  has_many :games
  belongs_to :dealer, class_name:'Dealer', foreign_key:'dealer_id', optional: true
  has_many :table_users
  has_many :users, through: :table_users

  before_save :set_dealer

  # @return <User>
  def add_user!(name_or_user)
    user = name_or_user.is_a?(User) ? name_or_user : User.find_or_create_by(name: name_or_user.strip)
    table_user = self.table_users.find_or_initialize_by(user_id: user.id)
    # is_new_record = table_user.new_record? # some flag even after save
    table_user.save

    user
  end

  # New game based on users w/ optional bet_amounts (default Hand::DEFAULT_BET_AMOUNT),
  #   create hand, and start game w/ cards passed
  # @bet_amounts_h <Hash of user_id => bet_amount>
  def create_game!(bet_amounts_h = {})
    game = Game.create(table_id: self.id, dealer_id: self.dealer_id)
    self.users.each do|u|
      game.add_hand_for_user!(u, bet_amounts_h[u.id] || Hand::DEFAULT_BET_AMOUNT)
    end
    game.start_game!
    game
  end

  private

  def set_dealer
    self.dealer_id ||= Dealer.default_dealer.id
  end
end