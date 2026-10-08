module GameTestHelper
  

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

  # Similates a user @name_or_user entering with initial bet
  # @return <Hand>
  def check_adding_user(game, name_or_user, bet_amount)
    new_user_new_hand = game.add_hand_for_user!(name_or_user, bet_amount)

    assert new_user_new_hand.is_a?(Hand)
    assert new_user_new_hand.new?
    assert new_user_new_hand.user.is_a?(Player)
    assert bet_amount, new_user_new_hand.total_bet_amount
    assert (User::DEFAULT_BALANCE - bet_amount), new_user_new_hand.user.balance

    new_user_new_hand
  end

  # Game created, user created (User2xxx), hand created, game started
  # @options
  #   :user_name_prefix <String> default 'User'
  #   :bet_amount <Numeric> default 5
  # @return <Hand>
  def create_game_then_hand(options = {})
    game = create_game_first

    user_name = "#{options[:user_name_prefix] || 'User'} #{1000 + rand(10000000000)}"
    bet_amount = options[:bet_amount] || 5
    hand = game.add_hand_for_user!(user_name, bet_amount)

    game.start_game!

    hand
  end
end