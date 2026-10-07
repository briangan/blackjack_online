class PlayCard < ApplicationRecord
  belongs_to :game, dependent: :destroy
  belongs_to :given_user, class_name:'User', optional: true

  def card
    Card.new(rank, suit)
  end

  def pass_to!(hand_or_hand_id)
    self.update(hand_id: hand_or_hand_id.is_a?(Hand) ? hand_or_hand_id.id : hand_or_hand_id)
  end
end