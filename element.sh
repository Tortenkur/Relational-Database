#!/bin/bash

# Setting variables
PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t -c"

# Checking argument
if  [[ -z $1 ]]
then
	echo Please provide an element as an argument.
else
	if [[ $1 =~ ^[0-9]+$ ]]
	# search db for element 
	then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
	else
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1'")
	fi
	if [[ -z $ATOMIC_NUMBER ]]
	then
		echo I could not find that element in the database.
	else
		# get information of Element and fill variables
		ELEMENT=$($PSQL "SELECT e.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type
			FROM elements e
			INNER JOIN properties p
			ON e.atomic_number = p.atomic_number
			INNER JOIN types t
			ON p.type_id = t.type_id
			WHERE e.atomic_number = $ATOMIC_NUMBER")
		echo $ELEMENT | while read ATOM_NUMBER BAR SYMBOL BAR NAME BAR MASS BAR MELT_POINT BAR BOIL_POINT BAR TYPE
		do
			echo "The element with atomic number $ATOM_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
		done
	fi
fi
