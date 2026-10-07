require "test_helper"

class GameTest < ActiveSupport::TestCase

  setup do
    Hand.delete_all
    Game.delete_all
  end

  test "Create game" do
    game = create_game_first

    # Totally new user
    new_name = "Newbie #{1000 + rand(10000000000)}"

    # Add without even amount argument 
    assert_raises ArgumentError do
      new_user_new_hand = game.add_user!(new_name)
    end

    new_bet_amount = 3.0
    new_user_new_hand = game.add_user!(new_name, new_bet_amount)

    assert new_user_new_hand.is_a?(Hand)
    assert new_user_new_hand.new?
    assert new_user_new_hand.user.is_a?(Player)
    assert new_bet_amount, new_user_new_hand.total_bet_amount
    assert (User::DEFAULT_BALANCE - new_bet_amount), new_user_new_hand.user.balance

    # Existing user w/ no hand

    # Add existing user out of balance

    # Existing user already has hand

    # TODO: check available actions for each phrase of the Hand

  end

  private 

  # @return <Game>
  def create_game_first
    game = Game.create!
    assert game.dealer.is_a?(Dealer)

    # PlayCard
    all_play_cards_count = game.play_cards.count
    assert_equal all_play_cards_count, (Game::COUNT_OF_DECKS_PER_GAME * Card::RANKS.size * Card::SUITS.size)
    assert_equal all_play_cards_count, game.available_play_cards.count

    assert_equal all_play_cards_count, game.play_cards.distinct.pluck(:order_index).size

    # Hand
    assert_equal 1, game.hands.count
    first_hand = game.hands.first
    assert_equal game.dealer_id, first_hand.user_id
    assert_equal 'NEW', first_hand.status

    game
  end
end
