require "test_helper"
require "helpers/game_test_helper"

class GameTest < ActiveSupport::TestCase
  include GameTestHelper

  setup do
    Hand.delete_all
    Game.delete_all
  end

  test "Create game by different user" do
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

    third_bet_amount = 12.5
    third_hand = check_adding_user(game, third_user, third_bet_amount)

    # Existing user already has hand
    second_user_balance_b4 = second_user.balance
    second_diff_bet_amount = 10.95
    second_hand_after = check_adding_user(game, second_user, second_diff_bet_amount)
    assert (second_hand.id != second_hand_after.id)
    second_user.reload
    assert second_diff_bet_amount, second_hand_after.total_bet_amount
    assert second_user.balance, second_user_balance_b4 - second_diff_bet_amount

    # Check hands so far
    assert 4, game.hands.count
    hand_user_ids_expected = [game.dealer_id, new_user_new_hand.user_id, second_user.id, second_user.id, third_user.id].sort
    assert_equal hand_user_ids_expected, game.hands.collect(&:user_id).sort

    # Start game, check passed cards
    game.start_game!

    game.hands.each do|hand|
      assert_equal 2, hand.play_cards.count
    end

    assert_equal (game.play_cards.count - game.hands.count * 2), game.available_play_cards.count

    # Each player should make move, and then dealer
  end

  
  




end
