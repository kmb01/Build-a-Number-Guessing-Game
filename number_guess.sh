#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter you username:"
read USERNAME

if [[ ${#USERNAME} -lt 22 ]]
then


GET_RESULT_USER=$($PSQL "select name, games_played, best_game from users where name = '$USERNAME'")
IFS='| $' read -r NAME GAMES_PLAYED BEST_GAME <<< "$GET_RESULT_USER"

  if [[ ! -z $GET_RESULT_USER ]]
  then
  
	  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
		PLAYED_COUNTER=$GAMES_PLAYED

  else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  CREATE_USER=$($PSQL "insert into users(name) values('$USERNAME')")

	PLAYED_COUNTER=0
  fi

GET_RESULT_NEW=$($PSQL "select games_played, best_game from users where name = '$USERNAME'")
IFS='| $' read -r NEW_PLAYED NEW_BEST <<< "$GET_RESULT_NEW"	


SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo -e "\nGuess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
((PLAYED_COUNTER++))
while true
do
((NUMBER_OF_GUESSES++))


read INPUT

INPUT=$(echo "$INPUT" | sed 's/^0*//')

	if [[ ! $INPUT =~ ^[0-9]+$ ]] || (( INPUT < 1 || INPUT > 1000 ))
	then
	echo "That is not an integer, guess again:"
	continue
	fi

	
	if (( $INPUT > $SECRET_NUMBER ))
	then
	  echo "It's lower than that, guess again:"
	elif (( $INPUT < $SECRET_NUMBER ))
  then
	  echo "It's higher than that, guess again:"
  else
		FINAL_GUESS=$((NUMBER_OF_GUESSES++))
	  echo "You guessed it in $FINAL_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"

		
		if (( $NEW_BEST > $FINAL_GUESS || $NEW_BEST == 0))
		then
		UPDATE_GAMES=$($PSQL "update users set games_played = $PLAYED_COUNTER, best_game = $FINAL_GUESS where name='$USERNAME'")
		else
		UPDATE_GAMES=$($PSQL "update users set games_played = $PLAYED_COUNTER where name='$USERNAME'")
		fi
		break
	fi
done
fi

