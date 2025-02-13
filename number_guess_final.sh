#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read INPUT_USERNAME
GET_RESULT_NAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT_USERNAME'")
if [[ -z $GET_RESULT_NAME ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$INPUT_USERNAME', 0, 0)")
    if [[ $INSERT_NEW_USER == "INSERT 0 1" ]]
      then
        echo "Welcome, $INPUT_USERNAME! It looks like this is your first time here."
    fi
    #GET_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    GET_GAMES_PLAYED=0
    GET_BEST_GAME=0
  else
    GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$INPUT_USERNAME'")
    GET_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$INPUT_USERNAME'")
    echo -e "\nWelcome back, $INPUT_USERNAME! You have played $GET_GAMES_PLAYED games, and your best game took $GET_BEST_GAME guesses."
fi


SECRET_NUMBER=$((1 + $RANDOM % 1000))
echo "Guess the secret number between 1 and 1000:"
#echo "SECRET IS $SECRET_NUMBER"
GUESSES=0
GUESS_NUMBER=0

while [[ -z $GUESS_NUMBER ]] || [[ $GUESS_NUMBER -ne $SECRET_NUMBER ]]
do
  read GUESS_NUMBER
   
    if [[ $GUESS_NUMBER =~ ^[1-9][0-9]{0,2}$|1000$ ]];
      then
        if [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]];
          then
            echo "It's lower than that, guess again:"
          elif [[ $GUESS_NUMBER -lt $SECRET_NUMBER ]]
            then
              echo "It's higher than that, guess again:" 
        fi
        #GUESSES=$((GUESSES+1))
      else
        echo "That is not an integer, guess again:"
    fi

    GUESSES=$((GUESSES+1))
done

GET_GAMES_PLAYED=$((GET_GAMES_PLAYED+1))

if [[ $GUESSES -lt $GET_BEST_GAME || $GET_BEST_GAME == 0 ]]; 
  then
    UPDATE_RESULTS=$($PSQL "UPDATE users SET best_game = $GUESSES, games_played = $GET_GAMES_PLAYED WHERE username = '$INPUT_USERNAME'")
  else
    UPDATE_RESULTS=$($PSQL "UPDATE users SET games_played = $GET_GAMES_PLAYED WHERE username = '$INPUT_USERNAME'")
fi

echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
