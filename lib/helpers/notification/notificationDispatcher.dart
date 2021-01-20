import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'collapseNotifications.dart';
import 'models.dart';
import 'notificationHelper.dart';

class NotificationDispatcher {
  static ToBeDispatchedNotifications toBeDispatchedNotifications =
      ToBeDispatchedNotifications();

  static Future<void> dispatchNotifications() async {
    int notifId = 1;
    List<NotificationData> notificationList = [];
    if (globals.collapseNotifications) {
      ToBeDispatchedNotifications collapsedNotifications =
          await collapseNotifications(
        NotificationDispatcher.toBeDispatchedNotifications,
      );
      if (collapsedNotifications.getAllLength() > 20) {
        //You've got more than twenty new notifications, even when collapsed
        await NotificationHelper.show(
          notifId,
          getTranslatedString("NewNotifications"),
          getTranslatedString(
            "yougotXnotifs",
            replaceVariables: [
              NotificationDispatcher.toBeDispatchedNotifications
                  .getAllLength()
                  .toString(),
            ],
          ),
          NotificationHelper.platformChannelSpecificsAlertAll,
        );
      } else {
        notificationList = collapsedNotifications.listOfAllNotifications();
      }
    } else {
      notificationList = NotificationDispatcher.toBeDispatchedNotifications
          .listOfAllNotifications();
    }

    if (notificationList.length != 0) {
      //Delete older notifications
      await NotificationHelper.cancelAll();
      //Go through all of the new notifications
      for (var i = 0; i < notificationList.length + 1; i++) {
        if (i == notificationList.length) {
          //End everything with a summary
          //But summaries only work if we got more than 3 notifications to group
          if (notificationList.length > 3) {
            await NotificationHelper.show(
              notifId,
              getTranslatedString("NewNotifications"),
              getTranslatedString(
                "yougotXnotifs",
                replaceVariables: [
                  (notificationList.length - 1).toString(),
                ],
              ),
              NotificationHelper.platformChannelSpecificsSummary,
              payload: "marks",
            );
          }
        } else {
          await NotificationHelper.show(
            notifId,
            notificationList[i].title,
            notificationList[i].subtitle,
            notificationList.length > 3
                ? NotificationHelper.platformChannelSpecifics
                : NotificationHelper.platformChannelSpecificsAlertAll,
            payload: notificationList[i].payload,
          );
        }
        notifId++;
      }
    }
    //Clear already sent notifications
    NotificationDispatcher.toBeDispatchedNotifications =
        ToBeDispatchedNotifications();
  }
}
