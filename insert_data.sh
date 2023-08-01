#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

insertTeam () {
	return $INSERTED_ELEMENT_ID
}
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
	if [[ $YEAR != year ]]
	then
		# fill DB
		# get winner id if winner exists, else put winner in teams table
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		if [[ -z $WINNER_ID ]]
		then
			RET_VAL=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
			WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		fi
		# get opponent id if opp exists, elst put opp in teams table
		OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		if [[ -z $OPP_ID ]]
		then
			RET_VAL=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
			OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		fi
		# put data in games table
		RET_VAL=$($PSQL "INSERT INTO games
			(year, round, winner_goals, opponent_goals, winner_id, opponent_id) 
			VALUES
			('$YEAR', '$ROUND', '$WIN_GOALS', '$OPP_GOALS', '$WINNER_ID', '$OPP_ID')")

	fi
done

echo "Insertion finished"
