#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

RANDOM_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))

echo $RANDOM_NUMBER

echo "Enter your username:"
read USERNAME

USERID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'") 
if [[ -z $USERID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$(echo $($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USERID") | sed 's/ //g')
  BEST_GAME=$(echo $($PSQL "SELECT MIN(no_of_guesses) FROM games WHERE user_id=$USERID") | sed 's/ //g')
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0

SAVE_GAME(){
  if [[ -z $USERID ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played) values('$USERNAME', 1)")
    USERID=$($PSQL "SELECT user_id FROM users where username='$USERNAME'")
  else
    UPDATE_USER=$($PSQL "UPDATE users set games_played=games_played+1 where user_id=$USERID")
  fi
  UPDATE_GAME=$($PSQL "INSERT INTO games(user_id, no_of_guesses) values('$USERID', $GUESS_COUNT)")
}

GUESS_NUMBER(){
  read GUSSED_NUMBER
  GUESS_COUNT=$((GUESS_COUNT + 1))
  if [[ ! $GUSSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESS_NUMBER
  elif [[ $GUSSED_NUMBER < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    GUESS_NUMBER
  elif [[ $GUSSED_NUMBER > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    GUESS_NUMBER
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    SAVE_GAME
  fi
}

GUESS_NUMBER
