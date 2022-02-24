# 1. Initialize deck
# 2. Deal cards to player and dealer
# 3. Player turn: hit or stay
#   - repeat until bust or "stay"
# 4. If player bust, dealer wins.
# 5. Dealer turn: hit or stay
#   - repeat until total >= 17
# 6. If dealer bust, player wins.
# 7. Compare cards and declare winner.

RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
SUITS = %w(Spades Hearts Diamonds Clubs)
TWENTY_ONE = 21
SEVENTEEN = 17

def prompt(str)
  puts "=> #{str}"
end

def display_rules
  prompt "Rules of the Game:
  - You are the 'Player'
  - 'Player' and 'Dealer' are dealt 2 cards from the deck.
  - 'Player' plays their hand first, 'Dealer' plays their hand second.
  - Choose to hit (draw cards) or stay (don't draw cards).
  - The 'total' is the sum of all card values in your hand.
  - Face cards are worth 10, Aces can be worth 1 or 11.
  - If the value of the Player or Dealer's hand exceeds 21, they bust.
  - The greater hand value wins if neither player busts.
  - If both hand values are equal, it is a push (tie).
  - First to win 5 rounds is declared winner of the game."
  puts ""
end

def initialize_deck
  RANKS.product(SUITS).shuffle
end

def total(cards)
  values = cards.map { |card| card[0] }

  sum = 0
  values.each do |value|
    if value == 'A'
      sum += 11
    elsif value.to_i == 0 # J, Q, K
      sum += 10
    else
      sum += value.to_i
    end
  end

  # Correct for Aces
  values.select { |value| value == 'A' }.count.times do
    sum -= 10 if sum > TWENTY_ONE
  end

  sum
end

def busted?(cards)
  total(cards) > TWENTY_ONE
end

def winner_of_round(player_hand, dealer_hand)
  if total(player_hand) == total(dealer_hand)
    'Push'
  elsif busted?(player_hand)
    'Dealer'
  elsif busted?(dealer_hand)
    'Player'
  elsif total(player_hand) > total(dealer_hand)
    'Player'
  elsif total(dealer_hand) > total(player_hand)
    'Dealer'
  end
end

def display_results(player_hand, dealer_hand)
  case winner_of_round(player_hand, dealer_hand)
  when 'Push'
    prompt("This hand is a push.")
  when 'Player'
    prompt("Player, you won this hand!")
  when 'Dealer'
    prompt("Dealer won this hand!")
  end
end

def display_hand(cards)
  hand = cards.map do |card|
    card.join(' of ')
  end
  hand.join(', ')
end

def display_dealer_hand(cards)
  "#{cards[0].join(' of ')}"
end

def blackjack?(hand)
  total(hand) == TWENTY_ONE
end

def play_again?
  answer = ''
  prompt("Would you like to play again? (y or n)")
  loop do
    answer = gets.chomp.downcase
    if answer != 'y' && answer != 'n'
      puts "Please enter 'y' or 'n'"
    else
      break
    end
  end
  answer == 'y'
end

def next_round?
  answer = ''
  prompt("Are you ready to play the next round? (y or n)")
  loop do
    answer = gets.chomp.downcase
    if answer != 'y' && answer != 'n'
      puts "Please enter 'y' or 'n'."
    else
      break
    end
  end
  answer == 'y'
end

# rubocop:disable Style/LineEndConcatenation
def end_of_round_output(player_hand, dealer_hand)
  prompt "Dealer has: [#{display_hand(dealer_hand)}] " +
         "for a total of: *#{total(dealer_hand)}*"
  prompt "Player has: [#{display_hand(player_hand)}] " +
         "for a total of *#{total(player_hand)}*"
  puts "==============="
  puts ""

  puts "#{display_results(player_hand, dealer_hand)}"
end

def declare_winner?(player_wins, dealer_wins)
  player_wins == 5 || dealer_wins == 5
end

def display_winner_of_game(player_wins, dealer_wins)
  if player_wins == 5
    puts "*** Player wins the game! Congratulations!!! ***"
    puts ""
  elsif dealer_wins == 5
    puts "*** Dealer wins the game! Better luck next time. ***"
    puts ""
  end
end

player_wins = 0
dealer_wins = 0
loop do
  system 'clear'
  prompt "Welcome to Twenty-One! First to win 5 rounds wins the game. " +
         "Good luck!"
  display_rules

  deck = initialize_deck
  player_hand = []
  dealer_hand = []

  if declare_winner?(player_wins, dealer_wins)
    player_wins = 0
    dealer_wins = 0
  end

  2.times do
    player_hand << deck.pop
    dealer_hand << deck.pop
  end

  player_total = total(player_hand)
  dealer_total = total(dealer_hand)

  prompt "Dealer wins: #{dealer_wins}"
  prompt "Player wins: #{player_wins}"
  prompt "Dealer hand: [#{display_dealer_hand(dealer_hand)}, *Face down*]"
  prompt "Player hand: [#{display_hand(player_hand)}] " +
         "for a total of: *#{total(player_hand)}*"

  loop do # player turn
    player_turn = nil

    loop do
      prompt "Hit or Stay? (h or s)"
      player_turn = gets.chomp.downcase
      break if ['h', 's'].include?(player_turn)
      prompt "Please enter 'h' or 's'."
    end

    if player_turn == 'h'
      player_hand << deck.pop
      player_total = total(player_hand)
      prompt "You chose to hit!"
      prompt "Your cards are now: [#{display_hand(player_hand)}] " +
             "for a total of: *#{player_total}*"
    end

    break if player_turn == 's' || busted?(player_hand)
  end
  # rubocop:enable Style/LineEndConcatenation

  if busted?(player_hand)
    prompt "Player bust!"
    end_of_round_output(player_hand, dealer_hand)
    dealer_wins += 1

    if declare_winner?(player_wins, dealer_wins)
      display_winner_of_game(player_wins, dealer_wins)
      play_again? ? next : break
    else
      next_round? ? next : break
    end
  else
    prompt "You chose to stay!"
  end

  prompt "Dealer's turn..."

  loop do # Dealer turn
    break if dealer_total >= SEVENTEEN

    if dealer_total < SEVENTEEN
      prompt("Dealer hits!")
      dealer_hand << deck.pop
      dealer_total = total(dealer_hand)
    end
  end

  if busted?(dealer_hand)
    prompt "Dealer Bust!"
    end_of_round_output(player_hand, dealer_hand)
    player_wins += 1
    if declare_winner?(player_wins, dealer_wins)
      display_winner_of_game(player_wins, dealer_wins)
      play_again? ? next : break
    else
      next_round? ? next : break
    end
  end

  end_of_round_output(player_hand, dealer_hand)

  case winner_of_round(player_hand, dealer_hand)
  when 'Player blackjack'
    player_wins += 1
  when 'Dealer blackjack'
    dealer_wins += 1
  when 'Player'
    player_wins += 1
  when 'Dealer'
    dealer_wins += 1
  end

  if declare_winner?(player_wins, dealer_wins)
    display_winner_of_game(player_wins, dealer_wins)
    break unless play_again?
  else
    break unless next_round?
  end
end

prompt "Thanks for playing!"
