const functions = require('firebase-functions');
const admin = require('firebase-admin');


admin.initializeApp();

const auth = admin.auth();


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
//  exports.helloWorld = functions.https.onRequest((request, response) => {
//    functions.logger.info("Hello logs!", {structuredData: true});
//    response.send("Hello from Firebase!");
//  });


// exports.updatePassword = functions.firestore.document('users_update_poassword/{ID}').onCreate(async (snapshot) => {
//
//   if(!snapshot.data().password || !snapshot.data().userUID) {
//     return null;
//   } else {
//     const data = snapshot.data();
//     const password = data.password;
//     const userUID = data.userUID;
//
//     await admin.auth().updateUser(userUID, {
//       password: password
//     });
//
//
//   }
//
//
// });


/*
exports.updateUser = functions.https.onCall( (data, context) => {

});

*/

exports.makeUser = functions.https.onCall(async (data, context) => {

    console.log("ID: " + data.jwt);

    let idToken = data.jwt;

    await auth.verifyIdToken(idToken).then(async (claims) => {

        console.log("User verified");

        if ((await auth.getUser(claims.uid)).customClaims.isManager === true) {

            console.log('User is a manager');
            try {
                await auth.createUser({
                    displayName: data.name,
                    email: data.email,
                    phoneNumber: data.phoneNumber,
                    password: data.password,
                });

                try {
                    functions.auth.user().onCreate(async (user) => {

                        var customClaims = {
                            isManager: data.isManager,
                        }

                        await auth.setCustomUserClaims(user.uid, customClaims);

                        await admin.firestore().collection('users/' + user.uid).add({
                            name: user.displayName,
                            phoneNumber: user.phoneNumber,
                            isManager: user.customClaims.isManager,
                        })

                    });
                } catch (e) {
                    console.log(e);
                }

                console.log("User successfully created!")
            } catch (e) {
                console.log(e);
                return 'User creation failed! ' + e;
            }
        }
        console.log('User is not a manager');

    });


});

exports.editUser = functions.https.onCall(async (data, context) => {

    if (await auth.getUser(context.auth.uid) !== null) {

        let user = auth.getUserByEmail(data.email)


    } else {
        console.log('User does not exist');
    }

});

exports.getAllUsers = functions.https.onCall(async (data, context) => {


});