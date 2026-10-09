class CardsController < ApplicationController
  def index
    @cards = []
    Card::RANKS.each do|rank|
      Card::SUITS.each do|suit|
        @cards << Card.new(rank, suit)
      end
    end
  end
end