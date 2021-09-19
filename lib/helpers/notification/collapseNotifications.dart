import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/database/users.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

import 'models.dart';

Future<ToBeDispatchedNotifications> collapseNotifications(
    ToBeDispatchedNotifications input) async {
  FirebaseCrashlytics.instance.log("collapseNotifications");
  ToBeDispatchedNotifications output = new ToBeDispatchedNotifications();
  ToBeDispatchedNotificationsMatrix matrixInput =
      createNotificationMatrix(input);
  //? Marks
  if (matrixInput.marks.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.marks) {
      output.marks.add(
        await createNotificationData(
          n,
          "marks",
        ),
      );
    }
  } else if (matrixInput.marks.length != 0) {
    //Single user? No problem
    if (matrixInput.marks[0].length == 1) {
      //If it's a single notif it is good to go.
      output.marks.add(matrixInput.marks[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.marks.add(
        await createNotificationData(
          matrixInput.marks[0],
          "marks",
        ),
      );
    }
  }

  //? Notices
  if (matrixInput.notices.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.notices) {
      output.notices.add(
        await createNotificationData(
          n,
          "notice",
        ),
      );
    }
  } else if (matrixInput.notices.length != 0) {
    //Single user? No problem
    if (matrixInput.notices[0].length == 1) {
      //If it's a single notif it is good to go.
      output.notices.add(matrixInput.notices[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.notices.add(
        await createNotificationData(
          matrixInput.notices[0],
          "notice",
        ),
      );
    }
  }

  //? Homeworks
  if (matrixInput.homeworks.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.homeworks) {
      output.homeworks.add(
        await createNotificationData(
          n,
          "hw",
        ),
      );
    }
  } else if (matrixInput.homeworks.length != 0) {
    //Single user? No problem
    if (matrixInput.homeworks[0].length == 1) {
      //If it's a single notif it is good to go.
      output.homeworks.add(matrixInput.homeworks[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.homeworks.add(
        await createNotificationData(
          matrixInput.homeworks[0],
          "hw",
        ),
      );
    }
  }

  //? Exams
  if (matrixInput.exams.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.exams) {
      output.exams.add(
        await createNotificationData(
          n,
          "exam",
        ),
      );
    }
  } else if (matrixInput.exams.length != 0) {
    //Single user? No problem
    if (matrixInput.exams[0].length == 1) {
      //If it's a single notif it is good to go.
      output.exams.add(matrixInput.exams[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.exams.add(
        await createNotificationData(
          matrixInput.exams[0],
          "exam",
        ),
      );
    }
  }

  //? Event
  if (matrixInput.events.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.events) {
      output.events.add(
        await createNotificationData(
          n,
          "event",
        ),
      );
    }
  } else if (matrixInput.events.length != 0) {
    //Single user? No problem
    if (matrixInput.events[0].length == 1) {
      //If it's a single notif it is good to go.
      output.events.add(matrixInput.events[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.events.add(
        await createNotificationData(
          matrixInput.events[0],
          "event",
        ),
      );
    }
  }

  //? Absence
  if (matrixInput.absences.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.absences) {
      output.absences.add(
        await createNotificationData(
          n,
          "absence",
        ),
      );
    }
  } else if (matrixInput.absences.length != 0) {
    //Single user? No problem
    if (matrixInput.absences[0].length == 1) {
      //If it's a single notif it is good to go.
      output.absences.add(matrixInput.absences[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.absences.add(
        await createNotificationData(
          matrixInput.absences[0],
          "absence",
        ),
      );
    }
  }

  //? Timetable
  if (matrixInput.timetables.length > 1) {
    //If we are dealing with multiple users than send one notification for each user
    for (var n in matrixInput.timetables) {
      output.timetables.add(
        await createNotificationData(
          n,
          "timetable",
        ),
      );
    }
  } else if (matrixInput.timetables.length != 0) {
    //Single user? No problem
    if (matrixInput.timetables[0].length == 1) {
      //If it's a single notif it is good to go.
      output.timetables.add(matrixInput.timetables[0][0]);
    } else {
      //Otherwise create a collapsed one
      output.timetables.add(
        await createNotificationData(
          matrixInput.timetables[0],
          "timetable",
        ),
      );
    }
  }

  //? Average
  if (matrixInput.averages.length != 0) {
    //All average notification should be sent
    for (var n in matrixInput.averages) {
      output.averages.addAll(n);
    }
  }

  return output;
}

Future<NotificationData> createNotificationData(
  List<NotificationData> inputNotifications,
  String notificationType,
) async {
  String username = await getUsersNameFromUserId(
    inputNotifications[0].userId,
  );

  int editedItemLength = inputNotifications
      .where(
        (element) => element.isEdited,
      )
      .length;
  int newItemLength = inputNotifications.length - editedItemLength;
  List<String> replaceVariables = [
    newItemLength.toString(),
    editedItemLength.toString(),
  ];

  //These notifications have additional info to be displayed
  if (notificationType == "hw" ||
      notificationType == "timetable" ||
      notificationType == "exam" ||
      notificationType == "marks") {
    Set<String> additionalKeySet = Set();
    for (var n in inputNotifications) {
      additionalKeySet.add(n.additionalKey);
    }
    if (notificationType == "timetable") {
      replaceVariables[0] = inputNotifications.length.toString();
      replaceVariables[1] = additionalKeySet.join(", ");
      return NotificationData(
        title: getTranslatedString(
          "${notificationType}XsChanged",
          replaceVariables: [username],
        ),
        subtitle: getTranslatedString(
          "${notificationType}XnewAndXchanged",
          replaceVariables: replaceVariables,
        ),
        uid: null,
        userId: inputNotifications[0].userId,
        isEdited: false,
        payload: notificationType,
      );
    } else {
      replaceVariables.add(additionalKeySet.join(", "));
    }
  }

  if (newItemLength == 0) {
    return NotificationData(
      title: getTranslatedString(
        "${notificationType}XsChanged",
        replaceVariables: [username],
      ),
      subtitle: getTranslatedString(
        "${notificationType}Xchanged",
        replaceVariables: replaceVariables,
      ),
      uid: null,
      userId: inputNotifications[0].userId,
      isEdited: false,
      payload: notificationType,
    );
  } else if (editedItemLength == 0) {
    return NotificationData(
      title: getTranslatedString(
        "${notificationType}XsChanged",
        replaceVariables: [username],
      ),
      subtitle: getTranslatedString(
        "${notificationType}Xnew",
        replaceVariables: replaceVariables,
      ),
      uid: null,
      userId: inputNotifications[0].userId,
      isEdited: false,
      payload: notificationType,
    );
  }

  return NotificationData(
    title: getTranslatedString(
      "${notificationType}XsChanged",
      replaceVariables: [username],
    ),
    subtitle: getTranslatedString(
      "${notificationType}XnewAndXchanged",
      replaceVariables: replaceVariables,
    ),
    uid: null,
    userId: inputNotifications[0].userId,
    isEdited: false,
    payload: notificationType,
  );
}

ToBeDispatchedNotificationsMatrix createNotificationMatrix(
    ToBeDispatchedNotifications input) {
  ToBeDispatchedNotificationsMatrix output =
      new ToBeDispatchedNotificationsMatrix();
  //Marks
  int userIdBefore = -1;
  for (var n in input.marks) {
    if (userIdBefore != n.userId) {
      output.marks.add([]);
      userIdBefore = n.userId;
    }
    output.marks.last.add(n);
  }
  //Homeworks
  userIdBefore = -1;
  for (var n in input.homeworks) {
    if (userIdBefore != n.userId) {
      output.homeworks.add([]);
      userIdBefore = n.userId;
    }
    output.homeworks.last.add(n);
  }
  //Notices
  userIdBefore = -1;
  for (var n in input.notices) {
    if (userIdBefore != n.userId) {
      output.notices.add([]);
      userIdBefore = n.userId;
    }
    output.notices.last.add(n);
  }
  //Timetables
  userIdBefore = -1;
  for (var n in input.timetables) {
    if (userIdBefore != n.userId) {
      output.timetables.add([]);
      userIdBefore = n.userId;
    }
    output.timetables.last.add(n);
  }
  //Exams
  userIdBefore = -1;
  for (var n in input.exams) {
    if (userIdBefore != n.userId) {
      output.exams.add([]);
      userIdBefore = n.userId;
    }
    output.exams.last.add(n);
  }
  //Averages
  userIdBefore = -1;
  for (var n in input.averages) {
    if (userIdBefore != n.userId) {
      output.averages.add([]);
      userIdBefore = n.userId;
    }
    output.averages.last.add(n);
  }
  //Events
  userIdBefore = -1;
  for (var n in input.events) {
    if (userIdBefore != n.userId) {
      output.events.add([]);
      userIdBefore = n.userId;
    }
    output.events.last.add(n);
  }
  //Absences
  userIdBefore = -1;
  for (var n in input.absences) {
    if (userIdBefore != n.userId) {
      output.absences.add([]);
      userIdBefore = n.userId;
    }
    output.absences.last.add(n);
  }
  return output;
}
