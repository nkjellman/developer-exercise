class Card
  attr_accessor :suite, :name, :value

  def initialize(suite, name, value)
    @suite, @name, @value = suite, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITES = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
	dealtCard = @playable_cards[random]
    @playable_cards.delete_at(random)
	return dealtCard
  end

  def shuffle
    @playable_cards = []
    SUITES.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end
  
  # returns true if hand value is over 21
  def isBusted?
	return value > 21
  end

  # returns true if hand value is "soft" (contains an ace)
  def isSoft?
	isSoft = false;
	@cards.each do |card|
		if card.value.is_a? Array
			isSoft = true
			break
		end
	end
	return isSoft
  end
  
  # returns true if hand is a blackjack (21 in two cards)
  def isBlackjack?
	return value == 21 && cards.length == 2
  end

  # returns largest possible value for this hand less than 21 and if not possible the smallest value
  def value
	# array of po hand values
	values = [ 0 ]

	# iterate through all cards and add each to values
	@cards.each do |card|
		# if card has single value add it to each possible hand value
		if card.value.is_a? Integer
			values.map!{|i| i += card.value}
		# if card has multiple vlues create new hand values for each
		else
			newValues = []
			card.value.each do |v|
				dupValues = values.dup
				dupValues.map!{|i| i += v}
				newValues.concat(dupValues)
			end
			values = newValues
		end
	end
	
	# find best value to return
	retVal = values.min
	values.each do |v|
		if v <= 21 && v > retVal
			retVal = v
		end
	end
	
	return retVal
  end
end

class Player
  attr_accessor :hand

  def initialize
    @hand = Hand.new
  end
	
  # player always hits on less than 14
  def hitMe?
	return hand.value < 14
  end
end

class Dealer
  attr_accessor :hand

  def initialize
    @hand = Hand.new
  end
	
  # dealer hits on less than 17 or "soft 17" (e.g. ace six combo)
  def hitMe?
	if (hand.isSoft?)
		return hand.value <= 17
	else
		return hand.value < 17
	end
  end
end

require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suite_is_correct
    assert_equal @card.suite, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert(!@deck.playable_cards.include?(card))
  end
end

class HandTest < Test::Unit::TestCase
  def setup
	@deck = Deck.new
	@deck.shuffle
	@hand = Hand.new
  end
  
  def test_ten_of_spades
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
	assert_equal @card.value, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(!@hand.isSoft?)
  end
  
  def test_single_dealt_card
	@card = @deck.deal_card
	@hand.cards << @card
	if @card.value.is_a? Integer
		assert_equal @card.value, @hand.value
		assert(!@hand.isSoft?)
	else
		assert_equal @card.value.max, @hand.value
		assert(@hand.isSoft?)
	end
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
  end
  
  def test_two_dealt_card
	@card = @deck.deal_card
	@hand.cards << @card
	@value = 0
	if @card.value.is_a? Integer
		value = @card.value
		assert(!@hand.isSoft?)
	else
		value = @card.value.max
		assert(@hand.isSoft?)
	end
	@card = @deck.deal_card
	@hand.cards << @card
	if @card.value.is_a? Integer
		assert_equal value+@card.value, @hand.value
	else
		assert_equal value+@card.value.max, @hand.value
	end
	assert(!@hand.isBusted?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@hand.cards << @card
	assert_equal 12, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(!@hand.isSoft?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_ace_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@hand.cards << @card
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
	assert_equal 13, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_ten_of_spades_and_ace_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
	assert_equal 21, @hand.value
	assert(@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_ace_of_clubs_ace_of_spades
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:spades, :ace, [1,11])
	@hand.cards << @card
	assert_equal 12, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_ace_of_spades_and_ace_of_clubs_and_nine_of_hearts
    @card = Card.new(:spades, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:heaerts, :nine, 9)
	@hand.cards << @card
	assert_equal 21, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_four_aces
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:spades, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:diamonds, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:hearts, :ace, [1,11])
	@hand.cards << @card
	assert_equal 14, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_four_aces_and_ten_of_spades
	@card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:spades, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:diamonds, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:hearts, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
	assert_equal 14, @hand.value
	assert(!@hand.isBlackjack?)
	assert(!@hand.isBusted?)
	assert(@hand.isSoft?)
  end
  
  def test_ace_of_clubs_and_ten_of_spades
	@card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
	assert_equal 21, @hand.value
	assert(!@hand.isBusted?)
	assert(@hand.isBlackjack?)
	assert(@hand.isSoft?)
  end
  
  def test_ten_of_spades_and_ten_of_clubs_and_two_of_hearts
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:clubs, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:heaerts, :two, 2)
	@hand.cards << @card
	assert_equal 22, @hand.value
	assert(@hand.isBusted?)
	assert(!@hand.isBlackjack?)
	assert(!@hand.isSoft?)
  end
  
  def test_ten_of_spades_and_eight_of_clubs_and_three_of_hearts_and_ace_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@hand.cards << @card
    @card = Card.new(:clubs, :eight, 8)
	@hand.cards << @card
    @card = Card.new(:heaerts, :three, 3)
	@hand.cards << @card
    @card = Card.new(:clubs, :ace, [1,11])
	@hand.cards << @card
	assert_equal 22, @hand.value
	assert(@hand.isBusted?)
	assert(!@hand.isBlackjack?)
	assert(@hand.isSoft?)
  end
end

class PlayerTest < Test::Unit::TestCase
  def setup
	@player = Player.new
  end
  
  def test_ten_of_spades
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
	assert(@player.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@player.hand.cards << @card
	assert(@player.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_ten_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@player.hand.cards << @card
    @card = Card.new(:clubs, :ten, 10)
	@player.hand.cards << @card
	assert(!@player.hitMe?)
  end
  
  def test_ten_of_spades_and_three_of_diamonds
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
    @card = Card.new(:diamonds, :three, 3)
	@player.hand.cards << @card
	assert(@player.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_two_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@player.hand.cards << @card
    @card = Card.new(:clubs, :two, 2)
	@player.hand.cards << @card
	assert(!@player.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_three_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@player.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@player.hand.cards << @card
    @card = Card.new(:clubs, :three, 3)
	@player.hand.cards << @card
	assert(!@player.hitMe?)
  end
end

class DealerTest < Test::Unit::TestCase

  def setup
	@dealer = Dealer.new
  end
  
  def test_ten_of_spades
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_ten_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@dealer.hand.cards << @card
    @card = Card.new(:clubs, :ten, 10)
	@dealer.hand.cards << @card
	assert(!@dealer.hitMe?)
  end
  
  def test_ten_of_spades_and_three_of_diamonds
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :three, 3)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ten_of_spades_and_two_of_diamonds_and_two_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :two, 2)
	@dealer.hand.cards << @card
    @card = Card.new(:clubs, :two, 2)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ace_of_spades_and_five_of_diamonds
    @card = Card.new(:spades, :ace, [1,11])
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :five, 5)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ace_of_spades_and_six_of_diamonds
    @card = Card.new(:spades, :ace, [1,11])
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :six, 6)
	@dealer.hand.cards << @card
	assert(@dealer.hitMe?)
  end
  
  def test_ace_of_spades_and_seven_of_diamonds
    @card = Card.new(:spades, :ace, [1,11])
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :seven, 7)
	@dealer.hand.cards << @card
	assert(!@dealer.hitMe?)
  end
  
  def test_ten_of_spades_and_four_of_diamonds_and_three_of_clubs
    @card = Card.new(:spades, :ten, 10)
	@dealer.hand.cards << @card
    @card = Card.new(:diamonds, :four, 4)
	@dealer.hand.cards << @card
    @card = Card.new(:clubs, :three, 3)
	@dealer.hand.cards << @card
	assert(!@dealer.hitMe?)
  end
end

puts
print "Blackjack simulator\n"
puts

@deck = Deck.new
@deck.shuffle

@p1 = Player.new
@p2 = Player.new
@dealer = Dealer.new

puts "Dealing cards"
@p1.hand.cards << @deck.deal_card
@p2.hand.cards << @deck.deal_card
@dealer.hand.cards << @deck.deal_card
@p1.hand.cards << @deck.deal_card
@p2.hand.cards << @deck.deal_card
@dealer.hand.cards << @deck.deal_card

if @dealer.hand.isBlackjack?
	puts "Dealer has Blackjack!"
	puts
	puts
	puts "Results"
	if @p1.hand.isBlackjack?
		puts "Player one ties"
	else
		puts "Player one loses"
	end
	if @p2.hand.isBlackjack?
		puts "Player two ties"
	else
		puts "Player two loses"
	end
	puts
	puts
	return
else
	if @p1.hand.isBlackjack?
		puts "Player one has Blackjack!"
	end
	if @p2.hand.isBlackjack?
		puts "Player two has Blackjack!"
	end
	if @p1.hand.isBlackjack? && @p2.hand.isBlackjack?
		puts
		puts
		puts "Results"
		puts "Player one wins"
		puts "Player two wins"
		puts
		puts
		return
	end
end

if !@p1.hand.isBlackjack?
	puts
	puts "Player one's turn"
	while @p1.hitMe?
		print "Player one hits ", @p1.hand.value, "\n"
		@p1.hand.cards << @deck.deal_card
	end
	if @p1.hand.isBusted?
		puts "Player one busts"
	else
		print "Player one stands on ", @p1.hand.value, "\n"
	end
end

if !@p1.hand.isBlackjack?
	puts
	puts "Player two's turn"
	while @p2.hitMe?
		print "Player two hits ", @p2.hand.value, "\n"
		@p2.hand.cards << @deck.deal_card
	end
	if @p2.hand.isBusted?
		puts "Player two busts"
	else
		print "Player two stands on ", @p2.hand.value, "\n"
	end
end

if !@p1.hand.isBusted? || !@p2.hand.isBusted?
	puts
	puts "Dealer's turn"
	while @dealer.hitMe?
		print "Dealer hits ", @dealer.hand.value, "\n"
		@dealer.hand.cards << @deck.deal_card
	end
	if @dealer.hand.isBusted?
		puts "Dealer busts"
		puts
		puts
		puts "Results"
		puts "Player one wins"
		puts "Player two wins"
		puts
		puts
		return
	else
		print "Dealer stands on ", @dealer.hand.value, "\n"
	end

	puts
	puts "Results"
	if !@p1.hand.isBusted?
		if @p1.hand.value > @dealer.hand.value || @p1.hand.isBlackjack?
			puts "Player one wins"
		elsif @p1.hand.value == @dealer.hand.value
			puts "Player one ties"
		else
			puts "Player one loses"
		end
	else
		puts "Player one loses"
	end
	
	if !@p2.hand.isBusted?
		if @p2.hand.value > @dealer.hand.value || @p2.hand.isBlackjack?
			puts "Player two wins"
		elsif @p2.hand.value == @dealer.hand.value
			puts "Player two ties"
		else
			puts "Player two loses"
		end
	else
		puts "Player two loses"
	end
	puts
	puts
end
