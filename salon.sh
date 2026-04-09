#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~Welcome to MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"


# create function to loop through steps required to schedule the appointment and update database
MAIN_MENU() {
  # error message
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  # get services available
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # format output to desired format
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
 
  # get user input
   read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send back to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    
    else
      # get selected service 
      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      
      # if it's not valid
      if [[ -z $SERVICE_NAME_SELECTED ]]
        then
          # send back to main menu
          MAIN_MENU "Sorry, that is not a valid service. Please choose again."
        else
          
          # get customers phone number 
          echo -e "\nWhat is your phone number?"
          read CUSTOMER_PHONE
          
          # get customers name
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          # if not found
          if [[ -z $CUSTOMER_NAME ]]
            then
              # obtain new customers name
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME
              
              # insert new entry into db
              INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          fi
          
          # get appointment time
          echo -e "\n What time would you like to book the $SERVICE_NAME_SELECTED service, $CUSTOMER_NAME?"
          read SERVICE_TIME

          # get customer_id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          # insert appointment into db
          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")

          echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi 
  fi

}

MAIN_MENU
