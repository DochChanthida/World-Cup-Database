#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear old data
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# Insert unique teams
cat games.csv | tail -n +2 | while IFS=',' read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Insert winner
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ -z $TEAM_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
  fi

  # Insert opponent
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ -z $TEAM_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
  fi
done

# Insert games
cat games.csv | tail -n +2 | while IFS=',' read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)"
done
