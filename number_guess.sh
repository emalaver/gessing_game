#!/bin/bash
# Generates a random number between 1 and 1000 for users to guess.

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# random number generator
NUMBER=$(( RANDOM % 1000 ))

GAME() {
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  
  NUMBER_OF_GUESSES=1
  WINNER=0
  until (( $WINNER ))
  do
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESS
    done
    if [[ $GUESS -eq $NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
      WINNER=1
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
      NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
    else
      echo "It's lower than that, guess again:"
      read GUESS
      NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))  
    fi
  done
}

echo "Enter your username:"
read USERNAME

# get gamer id
GAMER_ID=$($PSQL "SELECT gamer_id FROM gamers WHERE name='$USERNAME'")
if [[ -z $GAMER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO gamers (name) VALUES ('$USERNAME')")
  # get the new gamer id
  GAMER_ID=$($PSQL "SELECT gamer_id FROM gamers WHERE name='$USERNAME'")
  GAME
else
  # get gamer info
  GAMER_INFO=$($PSQL "SELECT COUNT(gamer_id), MIN(number_of_guesses) FROM games JOIN gamers USING (gamer_id) WHERE gamer_id=$GAMER_ID")
  echo "$GAMER_INFO" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
  GAME
fi

# insert game result
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (number_of_guesses, gamer_id) VALUES ($NUMBER_OF_GUESSES, $GAMER_ID)")