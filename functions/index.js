const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const auth = admin.auth();
const firestore = admin.firestore();
const increment = admin.firestore.FieldValue.increment;

exports.makeUser = functions.region('us-west2').https.onCall(async (data, context) => {

    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {
        console.log("User verified");

        //Creates user
        try {
            let newUser = await auth.createUser({
                displayName: data.name,
                email: data.email,
                password: data.password,
            });

            //Sets custom claims for user
            await auth.setCustomUserClaims(newUser.uid, {
                isManager: data.isManager,
            });

            await firestore.doc('users/' + newUser.uid).create({
                email: data.email,
                isManager: data.isManager,
                name: data.name,
                phoneNumber: data.phoneNumber,
            });

            return 'success';

        } catch (reason) {
            console.log("An error occurred creating user! " + reason.code);
            return reason.code;
        }

    }
});

exports.deleteData = functions.region('us-west2').auth.user().onDelete(async (user, context) => {

    //Recursively deletes all collections under user collection
    await admin.firestore().recursiveDelete(admin.firestore().collection('users').doc(user.uid)).then(() => {

        console.log("User " + user.uid + " data was successfully deleted!");

    }).catch((reason) => {
        console.log("An error occurred deleting user data! " + reason.code);
    });

});

exports.deleteUser = functions.region('us-west2').https.onCall(async (data, context) => {

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

exports.updateUser = functions.region('us-west2').https.onCall(async (data, context) => {

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
                password: data.password,
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

exports.getMyExpenses = functions.region('us-west2').https.onCall(async (data, context) => {

    let receiptQuery = await firestore.collection("users/" + context.auth.uid + "/receipts").get();

    let foodTotal = 0;
    let toolsTotal = 0;
    let travelTotal = 0;
    let otherTotal = 0;
    let toolsExpensesMade = 0;
    let foodExpensesMade = 0;
    let travelExpensesMade = 0;
    let otherExpensesMade = 0;

    let receiptDocs = receiptQuery.docs;

    for(let i = 0; i < receiptDocs.length; i++) {

        const receiptDocReference = receiptDocs[i];

        switch(receiptDocReference.get('expenseType')) {
            case "Food":
                foodTotal += receiptDocReference.get('total');
                foodExpensesMade++;
                break;
            case "Tools":
                toolsTotal += receiptDocReference.get('total');
                toolsExpensesMade++;
                break;
            case "Travel":
                travelTotal += receiptDocReference.get('total');
                travelExpensesMade++;
                break;
            case "Other":
                otherTotal += receiptDocReference.get('total');
                otherExpensesMade++;
        }
    }

    return [foodTotal/100, toolsTotal/100, travelTotal/100, otherTotal/100,  foodExpensesMade, toolsExpensesMade, travelExpensesMade, otherExpensesMade];
});

exports.setReceiptCounts = functions.region('us-west2').firestore.document('users/{userID}/receipts/{receiptID}').onWrite(async (change, context) => {

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


exports.archive = functions.pubsub.schedule('0 0 * * 6').onRun(async(context) => {

    //TODO Make this not bad
    const usersQuerySnapshot = await firestore.collection('users').get();

    for(let i = 0; i < usersQuerySnapshot.size; i++) {

        const usersDocReference = await usersQuerySnapshot.docs[i].ref;

        const receiptColReference = await firestore.collection('users/' + usersDocReference.id + '/receipts');

        const receiptSnapshot = await receiptColReference.get();

        for(let j = 0; j < receiptSnapshot.size; j++) {
            const receiptDocReference = receiptSnapshot.docs[j];

            await firestore.collection('archivedReceipts').doc(usersDocReference.id).collection('receipts').doc(receiptDocReference.id).set(receiptDocReference.data());

        }


    }

});



exports.getExpenses = functions.region('us-west2').https.onCall(async (data, context) => {

    let user = await auth.getUser(context.auth.uid);

    if(user.customClaims.isManager) {

        const usersQuerySnapshot = await firestore.collection('users').get();

        let toolsTotal = 0;
        let travelTotal = 0;
        let foodTotal = 0;
        let otherTotal = 0;


        let cumulativeTotal = 0;
        let perUserTotal = 0;


        let toolsExpensesMade = 0;
        let travelExpensesMade = 0;
        let foodExpensesMade = 0;
        let otherExpensesMade = 0;
        let totalExpensesMade = 0;
        for(let i = 0; i < usersQuerySnapshot.size; i++) {

            const usersDocReference = await usersQuerySnapshot.docs[i].ref;

            const receiptColReference = await firestore.collection('users/' + usersDocReference.id + '/receipts');

            const receiptSnapshot = await receiptColReference.get();

            for(let j = 0; j < receiptSnapshot.size; j++) {
                const receiptDocReference = receiptSnapshot.docs[j];
                perUserTotal += receiptDocReference.get('total');

                switch(receiptDocReference.get('expenseType')) {
                    case "Food":
                        foodTotal += receiptDocReference.get('total');
                        foodExpensesMade++;
                        totalExpensesMade++;
                        break;
                    case "Tools":
                        toolsTotal += receiptDocReference.get('total');
                        totalExpensesMade++;
                        toolsExpensesMade++;
                        break;
                    case "Travel":
                        travelTotal += receiptDocReference.get('total');
                        totalExpensesMade++;
                        travelExpensesMade++;
                        break;
                    case "Other":
                        otherTotal += receiptDocReference.get('total');
                        totalExpensesMade++;
                        otherExpensesMade++;
                }

                if(j === receiptSnapshot.size - 1) {
                    cumulativeTotal += perUserTotal;
                    perUserTotal = 0;
                }
            }
        }
        return [foodTotal/100, toolsTotal/100, travelTotal/100, otherTotal/100, cumulativeTotal/100, foodExpensesMade, toolsExpensesMade, travelExpensesMade, otherExpensesMade, totalExpensesMade];
    }

});

