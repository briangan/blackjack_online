# README

---------------------------------
## Description

This is an online Blackjack card game to allow 1 or more players to play against the dealer.

----------------------------------
## References
  * Project documentation: in folder "doc", see ["Praeses_Blackjack_Homework_2026_WebApp.pdf"](doc/Praeses_Blackjack_Homework_2026_WebApp.pdf)
  * [Blackjack Rules](https://bicyclecards.com/how-to-play/blackjack/)
  * [Blackjack Wiki](https://www.wikihow.com/Play-Blackjack)

-------------------------------------
## Gameplay Steps
  ### Game Start
  * If New Game, shuffle a deck of 52; Else keep existing left over cards
  * Players: at least one users added to Table with bet amount, Start New Game
  * Pass out cards
    * First pass 2 cards to dealer; one face up and the other face down
    * Each player receives 2 cards; both cards face up
  
  ### Player Turns: For each Hand

  #### Initial action choices:
  * Hit: Take another card to add to the total.
  * Stand/Stay: Keep current total. End player's turn.
  * Double Down: Double the bet, take one final card, then stand.
  * Split: If a player have a pair of same, split into two hands by placing a second bet equal to first bet.
  
  #### Following action choices:
  * Hit: Take another card to add to the total.
  * Stand/Stay: Keep current total. End player's turn.

  #### Player's turn ends after all Hits and Stand chosen
  * If max value of Hand is more than 21, would be Bust and player loses and bet amount is subtracted from balance

  ### Dealer's Turn

  #### Action choices
  * Hit: Take another card to add to the total.
  * Stand/Stay: Keep current total. End player's turn.

  #### Player's turn ends after all Hits and Stand chosen
  * If max value of Hand is over 21, would be Bust and player loses

  ### Calculate each player's winning status
  * If player's max value is more than 21, player loses
  * Else if that max value equals to max value of the dealer, would be a tie 
  * Else if that max value is more than max value of the dealer, would be win

  ### Payout Amounts in Ratio of Bet Amount
  * Win: Pay 1:1 ratio of bet amount to balance
  * Win with Blackjack (Ace + 10‑value card): Pay 3:2 ratio of bet amount to balance
  * Tie: no change to balance
  * Lose: subtract bet amount from balance

------------------------------------
## Data Models
  * Table - has a Dealer, Players, and multiple Games
  * Game - a game play to win or lose against the dealer; has a Deck, and some Hands of PlayCards
  * Deck - has set of PlayCard which could be shuffled.  This model is optinal by direct reference of PlayCard.game_id
  * User - account authentication and attributes
  * Hand - one User or the dealer that has set of PlayCard
  * PlayCard - different from Card, the raw card with unique rank + suit combo in a deck.  Maybe future game might have multiple decks.
  * PlayerAction - as a log of choices made for the player's Hand

------------------------------------
## Server Environment
* Ruby version: 3.3+

* System dependencies: Rails 7+ in rubygems

* Configuration:
  * After ruby gems update, run "bin/bundle install"

* Database creation: using local SQLite

* Database initialization: run "bin/rake db:migrate"

* How to run the test suite: run "bin/rails test"

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

---------------------------------------
## Future TODOs

### User
  * Actual user registration and authentication

### Table
  * Default show Table page to show latest incomplete Game
  * Starting new Game would cancel the old incomplete

### Game Play
  * Separate each hand's actions to respond on the logged-in user's view of page; and verify
  * Some rules to automate dealer's actions
  * Broadcast moves to each player's browser using ActionCable

### UI
  * Animation passing out cards
  * Animation for disclosing hand of cards