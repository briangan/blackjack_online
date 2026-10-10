# Columns: game_id hand_id order_index rank suit
class PlayCard < ApplicationRecord
  belongs_to :game
  belongs_to :given_user, class_name:'User', optional: true

  attr_accessor :hide_face_down

  delegate :all, to: :card

  scope :available, -> { where("hand_id IS NULL") }

  def card
    Card.new(rank, suit)
  end

  def pass_to!(hand_or_hand_id)
    self.update(hand_id: hand_or_hand_id.is_a?(Hand) ? hand_or_hand_id.id : hand_or_hand_id)
  end
end