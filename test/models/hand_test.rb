require "test_helper"

class HandTest < ActiveSupport::TestCase

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
    assert_equal nil, hand.best_total_value
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
end