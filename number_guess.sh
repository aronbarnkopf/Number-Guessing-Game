#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game_db -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Trim whitespace just in case
USERNAME=$(echo "$USERNAME" | xargs)

# Get user data
USER_DATA=$($PSQL "SELECT games_played, best_guess FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert user or mark as new
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_guess) VALUES('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  else
    (( NUMBER_OF_GUESSES++ ))
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      echo "It's higher than that, guess again:"
      read GUESS
    fi
  fi
done

# Update database after game completion
(( GAMES_PLAYED++ ))

if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_guess = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
else
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"