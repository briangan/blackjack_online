require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "Create game" do
    game = Game.create!
    assert game.dealer.is_a?(Dealer)

    assert_equal game.play_cards.count, (Game::COUNT_OF_DECKS_PER_GAME * Card::RANKS.size * Card::SUITS.size)
  end
end
