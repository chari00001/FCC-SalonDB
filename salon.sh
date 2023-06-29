#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
    else
      echo -e "\nWelcome to My Salon, how can I help you?"
      SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
      echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo  "$SERVICE_ID) $SERVICE_NAME"
      done
      read SERVICE_ID_SELECTED
      SERVICE_SELECTION_RESULT=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
      if [[ -z $SERVICE_SELECTION_RESULT ]]
        then
          echo -e "\nI could not find that service. What would you like today?"
          MAIN_MENU
        else
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
          if [[ -z $CUSTOMER_EXISTS ]]
            then
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME
              INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
              if [[ $INSERT_CUSTOMER_RESULT = 'INSERT 0 1' ]]
                then
                  CUSTOMER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
              fi
          fi
          CUSTOMER_ID=$CUSTOMER_EXISTS
          echo $CUSTOMER_EXISTS
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | sed 's/^ //')
          echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
          read SERVICE_TIME
          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
            then
              SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;" | sed 's/^ //')
              echo "Service name selected: $SERVICE_NAME_SELECTED"
              echo "Service id selected: $SERVICE_ID_SELECTED"
              echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
            else
              MAIN_MENU "There is an error occured while creating an appointment, please try again."
          fi
      fi
  fi
}

MAIN_MENU