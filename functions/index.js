const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const auth = admin.auth();
const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.makeUser = functions.runWith({allowInvalidAppCheckToken: false}).region('us-west2').https.onCall(async (data, context) => {
    
    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {
        console.log("User verified");

        //Creates user
        try {
            let newUser = await auth.createUser({
                displayName: data.name,
                email: data.email,
                password: "password", //Default password for new user, they're prompted to change it when they first log in
            });

            //Sets custom claims for user
            await auth.setCustomUserClaims(newUser.uid, {
                isManager: data.isManager,
            });

            //Creates a user document
            await firestore.doc('users/' + newUser.uid).create({
                email: data.email,
                isManager: data.isManager,
                name: data.name,
                phoneNumber: data.phoneNumber,
            });

            //Creates a stats document for the user
            await firestore.doc('stats/' + newUser.uid).create({
                foodCount: 0,
                foodTotal: 0,
                otherCount: 0,
                otherTotal: 0,
                receiptCount: 0,
                receiptTotal: 0,
                toolsCount: 0,
                toolsTotal: 0,
                travelCount: 0,
                travelTotal: 0,
            });

            //Creates an isFirstSignIn document for the user, default is true, only false after first sign in
            await firestore.doc('isFirstSignIn/' + newUser.uid).create({
               isFirstSignIn: true,
            });

            return 'success';

        } catch (reason) {
            console.log("An error occurred creating user! " + reason.code);
            return reason.code;
        }

    }
});

exports.deleteData = functions.region('us-west2').auth.user().onDelete(async (user, context) => {

    //Recursively deletes all subcollections under user collection
    await admin.firestore().recursiveDelete(admin.firestore().collection('users').doc(user.uid)).then(() => {

        console.log("User " + user.uid + " data was successfully deleted!");

    }).catch((reason) => {
        console.log("An error occurred deleting user data! " + reason.code);
    });

});

exports.deleteUser = functions.runWith({allowInvalidAppCheckToken: false}).region('us-west2').https.onCall(async (data, context) => {


    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {

        let deletedUser = await auth.getUserByEmail(data.email);

        if(user.uid === deletedUser.uid) {
            console.log("User cannot delete themself!");
            return "can't delete self";
        } else {
            try {
                await auth.deleteUser(deletedUser.uid);
                return 'success';
            } catch (reason) {
                console.log("An unknown error occurred!");
                return reason.code;
            }
        }
    }
});

exports.updateUser = functions.runWith({allowInvalidAppCheckToken: false}).region('us-west2').https.onCall(async (data, context) => {


    let user = await auth.getUser(context.auth.uid);
    if(user.customClaims.isManager) {

        try {
            console.log(data.oldEmail);
            let updatedUser = await auth.getUserByEmail(data.oldEmail);

            await auth.setCustomUserClaims(updatedUser.uid, {
                isManager: data.isManager
            });

            await auth.updateUser(updatedUser.uid, {
                displayName: data.name,
                email: data.email,
            });

            await firestore.doc('users/' + updatedUser.uid).update({
                email: data.email,
                isManager: data.isManager,
                name: data.name,
                phoneNumber: data.phoneNumber,
            });

            return 'success';

        } catch (reason) {
            console.log("An error occurred updating user! " + reason.code);
            return reason.code;
        }
    }
});


exports.updateUserExpenses = functions.region('us-west2').firestore.document('users/{userID}/receipts/{receiptID}').onWrite(async (change, context) => {

    const userID = context.params.userID;
    const statsRef = firestore.collection('stats').doc(userID);

 if(!change.before.exists) {
        //On create
        let expenseType = change.after.get('expenseType');
        let total = change.after.get('total');

        switch(expenseType) {
            case 'Food':
                await statsRef.update({
                    receiptCount: increment(1),
                    receiptTotal: increment(total),
                    foodCount: increment(1),
                    foodTotal: increment(total),
                });
                break;
            case 'Travel':
                await statsRef.update({
                    receiptCount: increment(1),
                    receiptTotal: increment(total),
                    travelCount: increment(1),
                    travelTotal: increment(total),
                });
                break;
            case 'Tools':
                await statsRef.update({
                    receiptCount: increment(1),
                    receiptTotal: increment(total),
                    toolsCount: increment(1),
                    toolsTotal: increment(total),
                });
                break;
            case 'Other':
                await statsRef.update({
                    receiptCount: increment(1),
                    receiptTotal: increment(total),
                    otherCount: increment(1),
                    otherTotal: increment(total),
                });

        }
    } else if(change.before.exists && change.after.exists) {
        //On update
        let beforeExpenseType = change.before.get('expenseType');
        let afterExpenseType = change.after.get('expenseType');
        let beforeTotal = change.before.get('total');
        let afterTotal = change.after.get('total');

     if(beforeExpenseType !== afterExpenseType && beforeTotal !== afterTotal) {

         switch(beforeExpenseType) {
             case 'Food':
                 await statsRef.update({
                     foodCount: increment(-1),
                     foodTotal: increment(-beforeTotal),
                     receiptTotal: increment(-beforeTotal),
                 });
                 break;
             case 'Travel':
                 await statsRef.update({
                     travelCount: increment(-1),
                     travelTotal: increment(-beforeTotal),
                     receiptTotal: increment(-beforeTotal),
                 });
                 break;
             case 'Tools':
                 await statsRef.update({
                     toolsCount: increment(-1),
                     toolsTotal: increment(-beforeTotal),
                     receiptTotal: increment(-beforeTotal),
                 });
                 break;
             case 'Other':
                 await statsRef.update({
                     otherCount: increment(-1),
                     otherTotal: increment(-beforeTotal),
                     receiptTotal: increment(-beforeTotal),
                 });
         }

         switch(afterExpenseType) {
             case 'Food':
                 await statsRef.update({
                     foodCount: increment(1),
                     foodTotal: increment(afterTotal),
                     receiptTotal: increment(afterTotal),
                 });
                 break;
             case 'Travel':
                 await statsRef.update({
                     travelCount: increment(1),
                     travelTotal: increment(afterTotal),
                     receiptTotal: increment(afterTotal),
                 });
                 break;
             case 'Tools':
                 await statsRef.update({
                     toolsCount: increment(1),
                     toolsTotal: increment(afterTotal),
                     receiptTotal: increment(afterTotal),
                 });
                 break;
             case 'Other':
                 await statsRef.update({
                     otherCount: increment(1),
                     otherTotal: increment(afterTotal),
                     receiptTotal: increment(afterTotal),
                 });
         }


     } else if(beforeExpenseType !== afterExpenseType) {
            switch(beforeExpenseType) {
                case 'Food':
                    await statsRef.update({
                        foodCount: increment(-1),
                        foodTotal: increment(-beforeTotal)
                    });
                    break;
                case 'Travel':
                    await statsRef.update({
                        travelCount: increment(-1),
                        travelTotal: increment(-beforeTotal)
                    });
                    break;
                case 'Tools':
                    await statsRef.update({
                        toolsCount: increment(-1),
                        toolsTotal: increment(-beforeTotal)
                    });
                    break;
                case 'Other':
                    await statsRef.update({
                        otherCount: increment(-1),
                        otherTotal: increment(-beforeTotal)
                    });
            }

            switch(afterExpenseType) {
                case 'Food':
                    await statsRef.update({
                        foodCount: increment(1),
                        foodTotal: increment(beforeTotal)
                    });
                    break;
                case 'Travel':
                    await statsRef.update({
                        travelCount: increment(1),
                        travelTotal: increment(beforeTotal)
                    });
                    break;
                case 'Tools':
                    await statsRef.update({
                        toolsCount: increment(1),
                        toolsTotal: increment(beforeTotal)
                    });
                    break;
                case 'Other':
                    await statsRef.update({
                        otherCount: increment(1),
                        otherTotal: increment(beforeTotal)
                    });
            }
        } else if(beforeTotal !== afterTotal) {
            switch(beforeExpenseType) {
                case 'Food':
                    await statsRef.update({
                        receiptTotal: increment(-beforeTotal),
                        foodTotal: increment(-beforeTotal)
                    });
                    break;
                case 'Travel':
                    await statsRef.update({
                        receiptTotal: increment(-beforeTotal),
                        travelTotal: increment(-beforeTotal),
                    });
                    break;
                case 'Tools':
                    await statsRef.update({
                        receiptTotal: increment(-beforeTotal),
                        toolsTotal: increment(-beforeTotal),
                    });
                    break;
                case 'Other':
                    await statsRef.update({
                        receiptTotal: increment(-beforeTotal),
                        otherTotal: increment(-beforeTotal),
                    });
            }

            switch(afterExpenseType) {
                case 'Food':
                    await statsRef.update({
                        receiptTotal: increment(afterTotal),
                        foodTotal: increment(afterTotal)
                    });
                    break;
                case 'Travel':
                    await statsRef.update({
                        receiptTotal: increment(afterTotal),
                        travelTotal: increment(afterTotal),
                    });
                    break;
                case 'Tools':
                    await statsRef.update({
                        receiptTotal: increment(afterTotal),
                        toolsTotal: increment(afterTotal),
                    });
                    break;
                case 'Other':
                    await statsRef.update({
                        receiptTotal: increment(afterTotal),
                        otherTotal: increment(afterTotal),
                    });
            }

        }
    }
    else if(!change.after.exists) {
        //On delete
        let expenseType = change.before.get('expenseType');
        let total = change.before.get('total');

        switch(expenseType) {
            case 'Food':
                await statsRef.update({
                    receiptCount: increment(-1),
                    receiptTotal: increment(-total),
                    foodCount: increment(-1),
                    foodTotal: increment(-total),
                });
                break;
            case 'Travel':
                await statsRef.update({
                    receiptCount: increment(-1),
                    receiptTotal: increment(-total),
                    travelCount: increment(-1),
                    travelTotal: increment(-total),
                });
                break;
            case 'Tools':
                await statsRef.update({
                    receiptCount: increment(-1),
                    receiptTotal: increment(-total),
                    toolsCount: increment(-1),
                    toolsTotal: increment(-total),
                });
                break;
            case 'Other':
                await statsRef.update({
                    receiptCount: increment(-1),
                    receiptTotal: increment(-total),
                    otherCount: increment(-1),
                    otherTotal: increment(-total),
                });
        }
    }
});


exports.archive = functions.region('us-west2').pubsub.schedule('0 0 * * 6').onRun(async(context) => {

    const batch = firestore.batch();
    const usersQuerySnapshot = await firestore.collection('users').get();

    for(let i = 0; i < usersQuerySnapshot.size; i++) {
        const usersDocReference = await usersQuerySnapshot.docs[i].ref;

        const receiptColReference = await firestore.collection('users/' + usersDocReference.id + '/receipts');

        const receiptSnapshot = await receiptColReference.get();

        for(let j = 0; j < receiptSnapshot.size; j++) {
            const receiptDocReference = receiptSnapshot.docs[j];
            await firestore.collection('archivedReceipts').doc(usersDocReference.id).collection('receipts').doc(receiptDocReference.id).set(receiptDocReference.data());
            batch.delete(receiptSnapshot.docs[j].ref);
        }
    }
    //Delete all receipts after they've been archived
    await batch.commit();
});



exports.updateCumulativeStats = functions.region('us-west2').firestore.document('stats/{userID}').onUpdate(async (change, context ) => {

    const statsRef = firestore.doc('cumulativeStats/cumulativeStats');


    //On receiptCount change
    if(change.before.get('receiptCount') > change.after.get('receiptCount')) {

        await statsRef.update({
            cumulativeReceiptCount: increment(-1)
        });
    } else if(change.before.get('receiptCount') < change.after.get('receiptCount')) {

        await statsRef.update({
            cumulativeReceiptCount: increment(1)
        });
    }

    //On receiptTotal change
    if(change.before.get('receiptTotal') > change.after.get('receiptTotal')) {
        let total = change.after.get('receiptTotal') - change.before.get('receiptTotal');

        await statsRef.update({
            cumulativeReceiptTotal: increment(total)
        });
    } else if(change.before.get('receiptTotal') < change.after.get('receiptTotal')) {
        let total = change.after.get('receiptTotal') - change.before.get('receiptTotal');
        await statsRef.update({
            cumulativeReceiptTotal: increment(total)
        });
    }


    //On foodCount change
    if(change.before.get('foodCount') > change.after.get('foodCount')) {

        await statsRef.update({

            cumulativeFoodCount: increment(-1)

        });
    } else if(change.before.get('foodCount') < change.after.get('foodCount')) {

        await statsRef.update({
            cumulativeFoodCount: increment(1)
        });
    }

    //on foodTotal change
    if(change.before.get('foodTotal') > change.after.get('foodTotal')) {
        let total = change.after.get('foodTotal') - change.before.get('foodTotal');

        await statsRef.update({
            cumulativeFoodTotal: increment(total)
        });

    } else if(change.before.get('foodTotal') < change.after.get('foodTotal')) {
        let total = change.after.get('foodTotal') - change.before.get('foodTotal');

        await statsRef.update({
            cumulativeFoodTotal: increment(total),
        });
    }

    //On otherCount change
    if(change.before.get('otherCount') > change.after.get('otherCount')) {

        await statsRef.update({

            cumulativeOtherCount: increment(-1)

        });
    } else if(change.before.get('otherCount') < change.after.get('otherCount')) {

        await statsRef.update({
            cumulativeOtherCount: increment(1)
        });
    }

    //On otherTotal change
    if(change.before.get('otherTotal') > change.after.get('otherTotal')) {
        let total = change.after.get('otherTotal') - change.before.get('otherTotal');

        await statsRef.update({
            cumulativeOtherTotal: increment(total)
        });

    } else if(change.before.get('otherTotal') < change.after.get('otherTotal')) {
        let total = change.after.get('otherTotal') - change.before.get('otherTotal');

        await statsRef.update({
            cumulativeOtherTotal: increment(total),
        });
    }



    //On toolsCount change
    if(change.before.get('toolsCount') > change.after.get('toolsCount')) {

        await statsRef.update({

            cumulativeToolsCount: increment(-1)

        });
    } else if(change.before.get('toolsCount') < change.after.get('toolsCount')) {

        await statsRef.update({
            cumulativeToolsCount: increment(1)
        });
    }

    //On toolsTotal change
    if(change.before.get('toolsTotal') > change.after.get('toolsTotal')) {
        let total = change.after.get('toolsTotal') - change.before.get('toolsTotal');

        await statsRef.update({
            cumulativeToolsTotal: increment(total)
        });

    } else if(change.before.get('toolsTotal') < change.after.get('toolsTotal')) {
        let total = change.after.get('toolsTotal') - change.before.get('toolsTotal');

        await statsRef.update({
            cumulativeToolsTotal: increment(total),
        });
    }


    //On travelCount change
    if(change.before.get('travelCount') > change.after.get('travelCount')) {

        await statsRef.update({

            cumulativeTravelCount: increment(-1)

        });
    } else if(change.before.get('travelCount') < change.after.get('travelCount')) {

        await statsRef.update({
            cumulativeTravelCount: increment(1)
        });
    }

    //On travelTotal change
    if(change.before.get('travelTotal') > change.after.get('travelTotal')) {
        let total = change.after.get('travelTotal') - change.before.get('travelTotal');

        await statsRef.update({
            cumulativeTravelTotal: increment(total)
        });

    } else if(change.before.get('travelTotal') < change.after.get('travelTotal')) {
        let total = change.after.get('travelTotal') - change.before.get('travelTotal');

        await statsRef.update({
            cumulativeTravelTotal: increment(total),
        });
    }


});
