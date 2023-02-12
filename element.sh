#!/bin/bash

# Script for retrieving element data from database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

DetermineArgType() {

  if [[ $1 =~ ^[0-9]+$ ]]
  then
    echo "atomic_number"
  elif [[ $1 =~ ^[A-Za-z]$ ]]
  then
    echo "symbol"
  else
    echo "name"
  fi
}

CreateOutput() {
  elementRecord=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE $1='$2';")
  if [[ -z $elementRecord ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$elementRecord" | while IFS="|" read atomicNumber symbol name
    do
      propertiesRecord=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$atomicNumber;")
      echo "$propertiesRecord" | while IFS="|" read atomicMass meltingPoint boilingPoint typeStr
      do
        echo -n "The element with atomic number $atomicNumber is $name ($symbol). It's a $typeStr, with a mass of $atomicMass amu. $name has a melting point of $meltingPoint celsius and a boiling point of $boilingPoint celsius."
      done
    done
  fi

}

Main() {
  # Test if user has input an arg
  # If no arg, exit with phrase 'Please provide an element as an argument.'
  if [[ -z $1 ]]
  then
    echo -e "Please provide an element as an argument."
  else
    input=$1
    testValue=$(DetermineArgType $input)
    outputMessage=$(CreateOutput $testValue $input)
    echo "$outputMessage"
  fi

}



# If arg is in list of names, symbols, or numbers, output formatted line of information

# If arg not in list, output not found statement

# Execute main()
Main $1