#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~Salon Appointment Scheduler~~~"

#Start Menu
MAIN_MENU () {
	echo -e "\n$1"
	SERVICES=$($PSQL "select service_id, name from services")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do	
		echo "$SERVICE_ID) $SERVICE_NAME"
	done
	
	# Processing user input/chosen service
	read SERVICE_ID_SELECTED
	SERVICE_AVAILABILITY=$($PSQL "Select service_id FROM services where service_id = $SERVICE_ID_SELECTED")
	if [[ -z $SERVICE_AVAILABILITY ]]
	then
		MAIN_MENU "I could not find that service. What would you like today?"
	else
		echo -e "\nPlease enter your phone number:"
		read CUSTOMER_PHONE
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		if [[ -z $CUSTOMER_ID ]]
		then
			echo -e "\nI don't have a record for that phone number, what's your name?"
			read CUSTOMER_NAME
			CUSTOMER_IS_INSERTED=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		else
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")	
		fi
		echo -e "\nPlease enter a time for the appointment"
		read SERVICE_TIME
		SERVICE_TIME_IS_ADDED=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

		if [[ $SERVICE_TIME_IS_ADDED =~ ^INSERT ]]
		then
			SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
			echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
		fi
	fi


}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"
