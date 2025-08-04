#! /bin/bash

# Función para mostrar servicios
mostrar_servicios() {
  echo -e "\nBienvenido a la Peluquería, elige un servicio:\n"
  psql --username=freecodecamp --dbname=salon -t -A \
    -c "SELECT service_id, name FROM services ORDER BY service_id;" \
    | while IFS='|' read id nombre; do
        echo "$id) $nombre"
      done
}

# 1) Mostrar y validar servicio
mostrar_servicios
read SERVICE_ID_SELECTED

# si no existe, repite
until [[ $(psql --username=freecodecamp --dbname=salon -t -A \
    -c "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;") ]]; do
  echo -e "\nNo es un servicio válido. Por favor elige de nuevo."
  mostrar_servicios
  read SERVICE_ID_SELECTED
done

# 2) Pedir número de teléfono
echo -e "\nIngresa tu número de teléfono:"
read CUSTOMER_PHONE

# 3) Verificar si es cliente nuevo
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A \
  -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nNo te tengo registrado. ¿Cómo te llamás?"
  read CUSTOMER_NAME
  psql --username=freecodecamp --dbname=salon \
    -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
fi

# 4) Pedir hora del turno
echo -e "\n¿A qué hora querés tu turno, $CUSTOMER_NAME?"
read SERVICE_TIME

# 5) Agendar la cita
psql --username=freecodecamp --dbname=salon \
  -c "INSERT INTO appointments(customer_id, service_id, time)
      VALUES(
        (SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'),
        $SERVICE_ID_SELECTED,
        '$SERVICE_TIME'
      );"

# 6) Confirmación final
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A \
  -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"