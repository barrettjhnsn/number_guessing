#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME

RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")

if [[ -z $RETURNING_USER ]]
then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

echo -e "\nGuess the secret number between 1 and 1000:\n"
read GUESS
NUMBER_GUESSES=1

while [[ $GUESS =~ ^[0-9]+$ && ! $GUESS -eq $SECRET_NUMBER ]]
do



  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then

    echo "It's lower than that, guess again:"
    read GUESS

  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then

    echo "It's higher than that, guess again:"
    read GUESS

  fi
NUMBER_GUESSES=$(expr $NUMBER_GUESSES + 1)
done

if [[ ! $GUESS =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
    read GUESS
fi

# Insert data from game
INSERT_GAME=$($PSQL "INSERT INTO games (user_id, guesses, secret_number) VALUES ($USER_ID, $NUMBER_GUESSES, $SECRET_NUMBER)")
echo -e "\nYou guessed it in $NUMBER_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
exit 0