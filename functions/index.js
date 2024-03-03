// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const functions = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Query} = require("firebase-admin/firestore");


initializeApp();

const firestore = getFirestore();

exports.setUpUser = functions.auth.user().onCreate(async (user) => {
    const email = user.email; 
    const displayName = user.displayName;
    const photo = user.photoURL;
    return firestore
    .collection("users").doc(user.uid).set({
        email: email,
        displayName: displayName,
        score: 0,
        createdAt: new Date(),
        photo: photo,
        games: [],
        wins: 0,
        losses: 0,
        draws: 0,
        waiting: false,
        inGame: false,
        currentGameID: null,
        uid: user.uid
    })
    .then(() => {
        console.log("user created: " + user.uid);
    })
});

exports.matchmaking = functions.firestore.document("users/{userID}").onUpdate(async (change, context) => {
    const userID = context.params.userID;
    const newlyWaiting = change.after.data().waiting && !change.before.data().waiting;
    const usersRef  = firestore.collection("users");
    const user = await firestore.collection("users").doc(userID).get();
    const userDoc = user.data();
    const q = firestore.collection("users").where("waiting", "==", true).where("uid", "!=", userID).limit(1);
    if (newlyWaiting) {
        console.log("matchmaking Triggered");

        const querySnapshot = await q.get();
        querySnapshot.forEach(async (doc) => {
            console.log("match found");
            const secondPlayer = doc.data();
            
            const board = new Array(42).fill(0);
            const players = [userID, doc.id];
            const p1Num = Math.floor(Math.random() * (2));
            const p2Num = p1Num === 0 ? 1 : 0;
            console.log("player"+p1Num + ": " + players[p1Num] +" player"+p2Num + ": " + players[p2Num]);
            const game  = await firestore.collection("games").add({
                player1: players[p1Num],
                player2: players[p2Num],
                createdAt: new Date(),
                turn: players[p1Num],
                board: board,
                winner: null,
            })
            console.log("game created");
            usersRef.doc(userDoc.uid).update({
                waiting: false,
                inGame: true,
                currentGameID: game.id,
                games: userDoc.games.concat(game.id)
            });
            console.log("user updated");
            doc.ref.update({
                waiting: false,
                inGame: true,
                currentGameID: game.id,
                games: secondPlayer.games.concat(game.id)
            });
            console.log("opponent updated");

            console.log("game id :" +game.id)
            return game.id;

        });

    }
    return null;
});

exports.updateScores = functions.firestore.document("games/{gameID}").onUpdate(async (change, context) => {
    const previous = change.before.data();
    const current = change.after.data();
    p1ID = current.player1;
    p2ID = current.player2;
    const player1Ref = firestore.collection("users").doc(p1ID);
    const player2Ref = firestore.collection("users").doc(p2ID);
    let player1 = await player1Ref.get()
    player1 = player1.data();
    let player2 = await player2Ref.get()
    player2 = player2.data();

    if (previous.winner !== current.winner) {
        if (current.winner === p1ID) {
            player1Ref.update({
                score: player1.score + 1,
                wins: player1.wins + 1,
                inGame: false,
                lastGame: current
            
            });
            player2Ref.update({
                losses: player2.losses + 1,
                score: player2.score - 1,
                inGame: false,
                lastGame: current

            });
        } else if (current.winner === p2ID) {
            player2Ref.update({
                score: player2.score + 1,
                wins: player2.wins + 1,
                inGame: false,
                lastGame: current

            });
            player1Ref.update({
                losses: player1.losses + 1,
                score: player1.score - 1,
                inGame: false,
                lastGame: current

            });
        }
        else if (current.winner === "draw"){
        player1Ref.update({
            draws: player1.draws + 1,
            inGame: false,
            lastGame: current

        });
        player2Ref.update({
            draws: player2.draws + 1,
            inGame: false,
            lastGame: current
        });
    }
    return null;
}
});


// exports.getMatch = onCall(async (request) => {
//     const uid = request.auth.uid;
//     const userRef = firestore.collection("users").doc(uid);
//     const user = await userRef.get();
//     const userDoc = user.data();
//     const q = firestore.collection("users").where("waiting", "==", true).where("uid", "!=", uid).limit(1);
//     const querySnapshot = await q.get();
//     querySnapshot.forEach(async (doc) => {
//         secondPlayer = doc.data();
//         const board = new Array(41).fill(0);

//         const game  = await firestore.collection("games").add({
//             player1: uid,
//             player2: doc.uid,
//             createdAt: new Date(),
//             turn: uid,
//             board: board,
//             winner: null,
//             draw: false

//         })
//         userRef.update({
//             waiting: false,
//             inGame: true,
//             currentGameID: game.id,
//             games: userDoc.games.concat(game.id)
//         });
//         doc.ref.update({
//             waiting: false,
//             inGame: true,
//             currentGameID: game.id,
//             games: secondPlayer.games.concat(game.id)
//         });

//         console.log("game id :" + game.id)
//         return game.id;

//     });
//     userRef.update({
//         waiting: true,
//         inGame: false,
//         currentGameID: null,
//     });

//     return null;


//   });
  