class PlayCard < ApplicationRecord
  belongs_to :game, dependent: :destroy
  belongs_to :given_user, class_name:'User', optional: true

  def card
    Card.new(rank, suit)
  end

  def pass_to!(user_id_or_user)
    self.update(user_id: user_id_or_user.is_a?(User) ? user_id_or_user.id : user_id_or_user)
  end
end