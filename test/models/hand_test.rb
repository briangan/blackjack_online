require "test_helper"
require "helpers/game_test_helper"

class HandTest < ActiveSupport::TestCase

  include GameTestHelper

  test "2 cards, no ace" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: '2', suit: 'Diamond'),
      PlayCard.new(rank: '9', suit: 'Diamond'),
    ]
    assert [11], hand.variants_of_total_value
    assert 11, hand.best_total_value
    assert !hand.busted?
  end

  test "3 cards, no ace" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: '2', suit: 'Diamond'),
      PlayCard.new(rank: '9', suit: 'Diamond'),
      PlayCard.new(rank: '6', suit: 'Diamond'),
    ]
    assert [17], hand.variants_of_total_value
    assert_equal 17, hand.best_total_value
    assert !hand.busted?
  end

  test "2 cards, one ace" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: 'A', suit: 'Diamond'),
      PlayCard.new(rank: '7', suit: 'Diamond'),
    ]
    assert [8, 18], hand.variants_of_total_value.sort
    assert_equal 18, hand.best_total_value
    assert !hand.busted?
  end

  test "2 aces" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: 'A', suit: 'Diamond'),
      PlayCard.new(rank: 'A', suit: 'Club'),
    ]
    assert [2, 12, 22], hand.variants_of_total_value.sort
    assert_equal 12, hand.best_total_value
    assert !hand.busted?
  end

  test "3 cards busted" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: '9', suit: 'Diamond'),
      PlayCard.new(rank: '4', suit: 'Club'),
      PlayCard.new(rank: '9', suit: 'Club'),
    ]
    assert [22], hand.variants_of_total_value.sort
    assert_nil hand.best_total_value
    assert hand.busted?
  end

  test "3 cards with ace, not busted and busted" do
    hand = Hand.new()
    hand.play_cards = [ 
      PlayCard.new(rank: '7', suit: 'Diamond'),
      PlayCard.new(rank: '8', suit: 'Club'),
      PlayCard.new(rank: 'A', suit: 'Club'),
    ]
    assert [16, 26], hand.variants_of_total_value.sort
    assert_equal 16, hand.best_total_value
    assert !hand.busted?
  end

  test "Status: turn not ended" do
    hand = Hand.new(status: 'NEW')
    hand.play_cards = [ 
      PlayCard.new(rank: '2', suit: 'Diamond'),
      PlayCard.new(rank: '9', suit: 'Diamond'),
    ]
    assert !hand.is_turn_ended?
  end

  test "Status: turn ended" do
    ::Hand::ENDED_STATUSES.each do|status|
      hand = Hand.new(status: status)
      hand.play_cards = [ 
        PlayCard.new(rank: '2', suit: 'Diamond'),
        PlayCard.new(rank: '9', suit: 'Diamond'),
      ]
      assert hand.is_turn_ended?
    end
  end

  ######################################
  # Play actions on the hand

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

  test "Double without Bust" do
    hand = create_game_then_hand

    # now keep hitting til busted
    puts "Double without Bust ------------------------"
    puts hand.to_s
    assert !hand.busted?

    how_many_before_bust = 21 - hand.variants_of_total_value.min
    next_available_card = hand.game.available_play_cards.first
    if next_available_card.card.min_value > how_many_before_bust # stay w/in range
      next_available_card.update(rank: Card.find_rank_with_value(how_many_before_bust) )
    end

    next_play_card = hand.double!
    puts "* HIT w/ card: #{next_play_card.card}"
    puts "  > #{hand}"

    assert hand.play_actions.last.is_a?(::PlayAction::Double)
    assert hand.stand?
    assert_equal next_available_card.id, next_play_card.id
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

end