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

    assert_raises Error::InsufficientBalanceForBetAmount do
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

  
  test "Win vs Dealer - Higher Value" do
    puts "Win vs Dealer - Higher Value --------------------" 
    hand = create_game_then_hand
    game = hand.game
    previous_balance = hand.user.balance

    force_this_higher_than_that(hand, game.dealer_hand)

    if game.dealer_hand.best_total_value < hand.best_total_value
      hand.stand!
      game.dealer_hand.stand!

      game.analyze_hands!

      game.dealer_hand.reload
      hand.reload # this is local compared to game.play_cards one

      game.hands.each do|h|
        puts h
      end
      
      assert hand.win?
      assert hand.user.balance, previous_balance + hand.total_bet_amount * hand.winning_return_amount_factor

    else # If somehow still cannot be higher, some data problem
    end
  end

  test "Win vs Dealer - Dealer Busted" do
    puts "Win vs Dealer - Dealer Busted --------------------" 
    hand = create_game_then_hand
    game = hand.game
    previous_balance = hand.user.balance

    hand.stand!

    while !game.dealer_hand.busted?
      game.dealer_hand.hit!
    end
  
    game.analyze_hands!
    game.dealer_hand.reload
    hand.reload # this is local compared to game.play_cards one

    game.hands.each do|h|
      puts h
    end

    assert game.dealer_hand.busted?

    assert hand.win?
    assert hand.user.balance, previous_balance + hand.total_bet_amount * hand.winning_return_amount_factor

  end

  test "Lose - Lower Value" do
    puts "Lose - Lower Value --------------------" 
    hand = create_game_then_hand
    game = hand.game
    previous_balance = hand.user.balance

    force_this_higher_than_that(game.dealer_hand, hand)

    if game.dealer_hand.best_total_value < hand.best_total_value
      hand.stand!
      game.dealer_hand.stand!

      game.analyze_hands!

      game.dealer_hand.reload
      hand.reload # this is local compared to game.play_cards one

      game.hands.each do|h|
        puts h
      end
      
      assert hand.win?
      assert hand.user.balance, previous_balance

    else # If somehow still cannot be higher, some data problem
    end
  end

  test "Lose - Busted" do
    puts "Lose - Busted --------------------" 
    hand = create_game_then_hand
    game = hand.game
    previous_balance = hand.user.balance

    hand.stand!

    while !hand.busted?
      hand.hit!
    end
  
    assert_raises ::Error::DealerNotFinished do
       game.analyze_hands!
    end
    game.dealer_hand.stand!

    game.dealer_hand.reload
    hand.reload # this is local compared to game.play_cards one

    game.hands.each do|h|
      puts h
    end

    assert hand.busted?

    assert hand.lose?
    assert hand.user.balance, previous_balance

  end

  test "Tie with Dealer - Same Value" do
    puts "Tie with Dealer - Same Value --------------------" 
    hand = create_game_then_hand
    game = hand.game
    previous_balance = hand.user.balance

    dealer_cards = game.dealer_hand.play_cards.all
    hand.play_cards.all.each_with_index do|pc, i|
      pc.update(rank: dealer_cards[i].rank, suit: dealer_cards[i].suit )
    end

    hand.reload
    hand.stand!
    game.dealer_hand.stand!

    game.analyze_hands!

    game.dealer_hand.reload
    hand.reload # this is local compared to game.play_cards one

    game.hands.each do|h|
      puts h
    end

    assert hand.tie?

    assert hand.user.balance, previous_balance + hand.total_bet_amount

  end

end
