#!/bin/bash

# Setting variables
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate number to guess
SECRET=$[ $RANDOM % 1000 + 1 ]

# Username recognition
echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
if [[ -z $USER_ID ]]
then
	echo "Welcome, $USERNAME! It looks like this is your first time here."
else
	GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $USER_ID")
	BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id = $USER_ID")
	echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Number guessing
COUNT=1
echo "Guess the secret number between 1 and 1000:"
read GUESS
while ! [[ $GUESS =~ ^[0-9]+$ ]]
do
		echo "That is not an integer, guess again:"
		read GUESS
done
while [[ $GUESS -ne $SECRET ]]
do
	
	if [[ $GUESS -gt $SECRET ]]
	then
		echo "It's lower than that, guess again:"
	else
		echo "It's higher than that, guess again:"
	fi
	COUNT=$[ $COUNT + 1 ]
	read GUESS
	while ! [[ $GUESS =~ ^[0-9]+$ ]]
	do
		echo "That is not an integer, guess again:"
		read GUESS
	done
done
# create user if it didn't exist
if [[ -z $USER_ID ]]
then
	CREATE_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
	USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
fi

# write stats into database
STATS_INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $COUNT)")

echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"



