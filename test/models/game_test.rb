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
      new_user_new_hand = game.add_hand_for_user!(new_name)
    end

    # Invalid bet amount
    assert_raises Error::InvalidBetAmountError do
      new_user_new_hand = game.add_hand_for_user!(new_name, -3)
    end

    new_bet_amount = 3.0
    new_user_new_hand = check_adding_user(game, new_name, new_bet_amount)

    # Existing user w/ no hand
    second_user_name = "Existing #{1000 + rand(10000000000)}"
    second_user = User.create!(name: second_user_name)
    assert_equal User::DEFAULT_BALANCE , second_user.balance

    second_bet_amount = 10.0
    assert_equal 0, game.hands.where(user_id: second_user.id).count

    second_hand = check_adding_user(game, second_user, second_bet_amount)
    assert_equal second_user.id, second_hand.user_id

    # Add existing user out of balance
    third_user_name = "Third #{1000 + rand(10000000000)}"
    third_user = User.create!(name: third_user_name)
    assert_equal User::DEFAULT_BALANCE , third_user.balance

    assert_raises Error::OutOfBalanceError do
      game.add_hand_for_user!(third_user, third_user.balance + 25)
    end

    # Existing user already has hand
    second_user_balance_b4 = second_user.balance
    second_diff_bet_amount = 10.95
    second_hand_after = check_adding_user(game, second_user, second_diff_bet_amount)
    assert (second_hand.id != second_hand_after.id)
    second_user.reload
    assert second_diff_bet_amount, second_hand_after.total_bet_amount
    assert second_user.balance, second_user_balance_b4 - second_diff_bet_amount

    assert 3, game.hands.count

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

  def check_adding_user(game, name_or_user, bet_amount)
    new_user_new_hand = game.add_hand_for_user!(name_or_user, bet_amount)

    assert new_user_new_hand.is_a?(Hand)
    assert new_user_new_hand.new?
    assert new_user_new_hand.user.is_a?(Player)
    assert bet_amount, new_user_new_hand.total_bet_amount
    assert (User::DEFAULT_BALANCE - bet_amount), new_user_new_hand.user.balance

    new_user_new_hand
  end
end
