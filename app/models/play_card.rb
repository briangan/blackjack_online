class PlayCard < ApplicationRecord
  belongs_to :game, dependent: :destroy
  belongs_to :given_user, class_name:'User', optional: true

  def card
    Card.new(rank, suit)
  end
end