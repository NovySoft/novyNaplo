import 'models.dart';

class NotificationDispatcher {
  static ToBeDispatchedNotifications toBeDispatchedNotifications =
      ToBeDispatchedNotifications();

  ///This function tells which notifs to collapse, and which ones are free to go
  static WhichToCollapse whichToCollapse(ToBeDispatchedNotifications input) {
    WhichToCollapse temp = new WhichToCollapse();
    return temp;
  }

  static Future<void> dispatchNotifications() async {
    WhichToCollapse whichToCollapse = NotificationDispatcher.whichToCollapse(
      NotificationDispatcher.toBeDispatchedNotifications,
    );
    print(whichToCollapse);
  }
}
