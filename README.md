# Connect 4
##  Description
This is a multiplayer Connect 4 game that supports realtime gameplay and matchmaking. 
### How matchmaking works
Each user has a document associated with them when the user clicks find match one of two things happens, if there is a user that has the waiting variable set to true both players get put in a match and their waiting variable is set to false, otherwise the players waiting variable is set to true and will be paired when another user clicks find match.
### How realtime game works
We took advantage of the fact that firestore is realtime to create a game document associated with each game. The current game id is stored in each user document until the game is done from there it was as simple as displaying the game by listening to events on the document.
## Technologies
-  Dart
-  Flutter
-  Firebase
-  JavaScript
