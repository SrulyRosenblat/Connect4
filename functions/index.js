// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const functions = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const { query, where , limit,getDocs,collection} = require("firebase/firestore");  

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Query} = require("firebase-admin/firestore");
const { re } = require("mathjs");

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
    console.log("matchmaking Triggered");
    const userID = context.params.userID;
    const newlyWaiting = change.after.data().waiting && !change.before.data().waiting;
    const usersRef  = firestore.collection("users");
    const user = await firestore.collection("users").doc(userID).get();
    const userDoc = user.data();
    console.log("userDoc");
    const q = firestore.collection("users").where("waiting", "==", true).where("uid", "!=", userID).limit(1);
    console.log("???");
    if (newlyWaiting) {
        const querySnapshot = await q.get();
        querySnapshot.forEach(async (doc) => {
            secondPlayer = doc.data();
            const board = new Array(41).fill(0);

            const game  = await firestore.collection("games").add({
                player1: userDoc,
                player2: doc.data(),
                createdAt: new Date(),
                turn: userDoc.uid,
                board: board,
                winner: null,
                draw: false

            })
            usersRef.doc(userDoc.uid).update({
                waiting: false,
                inGame: true,
                currentGameID: game.id,
                games: userDoc.games.concat(game.id)
            });
            doc.ref.update({
                waiting: false,
                inGame: true,
                currentGameID: game.id,
                games: secondPlayer.games.concat(game.id)
            });

            console.log("game id :" +game.id)
            return game.id;

        });

    }
    return null;
});
