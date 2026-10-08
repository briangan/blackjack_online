require "test_helper"

class GameTest < ActiveSupport::TestCase

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
  end

  test "Play Hit and Bust" do
    hand = create_game_then_hand

    # now keep hitting til busted
    puts "Hit and Bust ------------------------"
    puts hand.to_s
    assert !hand.busted?

    while hand.variants_of_total_value.min <= 21

      # HIT
      next_play_card = hand.hit!
      puts "* HIT w/ card: #{next_play_card.card}"
      puts "  > #{hand}"

      assert hand.play_actions.last.is_a?(::PlayAction::Hit)
    end

    assert hand.lose?
  end

  test "Play Stand" do
    hand = create_game_then_hand

    puts hand.to_s
    assert !hand.busted?

    hand.stand!

    assert hand.play_actions.last.is_a?(::PlayAction::Stand)
    assert hand.stand?
    assert !hand.lose?
  end

  test "Double and Bust" do
    hand = create_game_then_hand

    # now keep hitting til busted
    puts "Double and Bust ------------------------"
    puts hand.to_s
    assert !hand.busted?

    while hand.variants_of_total_value.min <= 21

      # HIT
      next_play_card = hand.double!
      puts "* HIT w/ card: #{next_play_card.card}"
      puts "  > #{hand}"

      assert hand.play_actions.last.is_a?(::PlayAction::Double)
    end

    assert hand.lose?
  end


  test "Split" do
    hand = create_game_then_hand

    puts "Split ------------------------"
    puts hand.to_s
    assert !hand.busted?

    play_card_ids = hand.play_cards.collect(&:id)
    first_card_rank = hand.play_cards.first.card.rank
    diff_card_rank = ::Card::RANKS.find{|r| r != first_card_rank }

    # Fail to split
    hand.play_cards.where("id != #{hand.play_cards.first.id}").update_all(rank: diff_card_rank)
    assert_raises ::Error::CannotSplitHand do
      hand.reload
      hand.split!
    end

    # Set all to same ranks
    hand.play_cards.update_all(rank: first_card_rank)
    hand.reload
    assert hand.can_split_now?
    second_hand = hand.split!
    
    assert 2, hand.play_cards.count
    assert 2, second_hand.play_cards.count

    assert !hand.play_cards.find{|pc| pc.id == play_card_ids[0] }.nil?
    assert hand.play_cards.find{|pc| pc.id == play_card_ids[1] }.nil?

    assert !second_hand.play_cards.find{|pc| pc.id == play_card_ids[1] }.nil?
    assert second_hand.play_cards.find{|pc| pc.id == play_card_ids[0] }.nil?
    
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

  # @return <Hand>
  def create_game_then_hand
    game = create_game_first

    user_name = "User #{1000 + rand(10000000000)}"
    bet_amount = 5
    hand = game.add_hand_for_user!(user_name, bet_amount)

    game.start_game!

    hand
  end
end
