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
    if (globals.collapseNotifications) {
      ToBeDispatchedNotifications collapsedNotifications =
          await collapseNotifications(
        NotificationDispatcher.toBeDispatchedNotifications,
      );
      print(collapsedNotifications.listOfAllNotifications());
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
          NotificationHelper.platformChannelSpecifics,
        );
      } else {
        //Less or equal to 20 notifications when collapsed, send them
        for (var n in collapsedNotifications.listOfAllNotifications()) {
          await NotificationHelper.show(
            notifId,
            n.title,
            n.subtitle,
            NotificationHelper.platformChannelSpecifics,
            payload: n.payload,
          );
          notifId++;
        }
      }
    } else {
      //Who would in their right mind would want this? Send all of the notifs
      for (var n in NotificationDispatcher.toBeDispatchedNotifications
          .listOfAllNotifications()) {
        await NotificationHelper.show(
          notifId,
          n.title,
          n.subtitle,
          NotificationHelper.platformChannelSpecifics,
          payload: n.payload,
        );
        notifId++;
      }
    }
  }
}
