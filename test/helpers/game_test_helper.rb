module GameTestHelper
  

  # @return <Game>
  def create_game_first
    table = Table.create
    game = Game.create!(table_id: table.id)
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


  # Modify either Hand's PlayCard to force @wanted_higher_hand > @wanted_lower_hand
  # @wanted_higher_hand <Hand>
  # @wanted_lower_hand <Hand>
  def force_this_higher_than_that(wanted_higher_hand, wanted_lower_hand)
    if wanted_higher_hand.best_total_value <= wanted_lower_hand.best_total_value
      diff = wanted_lower_hand.best_total_value - wanted_higher_hand.best_total_value

      if (deductable_card = wanted_lower_hand.play_cards.find{|pc| pc.card.max_value > 2 })
        deductable_card.update(rank: Card.find_rank_with_value(deductable_card.card.max_value - diff - 1) )
        wanted_lower_hand.reload

      elsif (raisable_card = wanted_higher_hand.play_cards.find{|pc| pc.card.max_value < 10 })
        raisable_card.update(rank: Card.find_rank_with_value(raisable_card.card.max_value + diff + 1) )
        wanted_higher_hand.reload
      end
    end
    wanted_higher_hand
  end
end