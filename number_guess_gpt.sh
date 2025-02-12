#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

if [[ ${#USERNAME} -le 22 ]]
then
  GET_RESULT_USER=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name = '$USERNAME'")

  if [[ -n "$GET_RESULT_USER" ]]
  then
    IFS='|' read -r NAME GAMES_PLAYED BEST_GAME <<< "$GET_RESULT_USER"
    NAME=$(echo "$NAME" | xargs)
    GAMES_PLAYED=$(echo "$GAMES_PLAYED" | xargs)
    BEST_GAME=$(echo "$BEST_GAME" | xargs)
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  else
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    CREATE_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    GAMES_PLAYED=0
    BEST_GAME=""
  fi

  ((GAMES_PLAYED++))
  SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
  echo -e "\nGuess the secret number between 1 and 1000:"

  NUMBER_OF_GUESSES=0

  while true
  do
    ((NUMBER_OF_GUESSES++))
    read INPUT

    INPUT=$(echo "$INPUT" | sed 's/^0*//')
    [[ -z "$INPUT" ]] && INPUT=0

    if [[ ! "$INPUT" =~ ^[0-9]+$ ]] || (( INPUT < 1 || INPUT > 1000 ))
    then
      echo "That is not an integer, guess again:"
      continue
    fi

    if (( INPUT > SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    elif (( INPUT < SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

      if [[ -z "$BEST_GAME" || "$BEST_GAME" -gt "$NUMBER_OF_GUESSES" ]]
      then
        UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $NUMBER_OF_GUESSES WHERE name='$USERNAME'")
      else
        UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE name='$USERNAME'")
      fi
      break
    fi
  done
fi
