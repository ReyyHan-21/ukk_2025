import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:elegant_notification/elegant_notification.dart';

class NotificationHelper {
  static void showError(BuildContext context, dynamic e) {
    if (context.mounted) {
      ElegantNotification.error(
        width: 360,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: const Text('Pesan'),
        description: Text(e.toString()),
        onDismiss: () {},
        onNotificationPressed: () {},
        isDismissable: true,
        dismissDirection: DismissDirection.up,
      ).show(context);
    }
  }

  static void showErrorMessage(BuildContext context, dynamic message) {
    if (context.mounted) {
      ElegantNotification.error(
        width: 360,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: const Text('Pesan'),
        description: Text(message.toString()),
        onDismiss: () {},
        onNotificationPressed: () {},
        isDismissable: true,
        dismissDirection: DismissDirection.up,
      ).show(context);
    }
  }

  static void showSuccess(BuildContext context, dynamic message) {
    if (context.mounted) {
      ElegantNotification.success(
        width: 360,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: const Text('Pesan'),
        description: Text(message.toString()),
        onDismiss: () {},
        onNotificationPressed: () {},
        isDismissable: true,
        dismissDirection: DismissDirection.up,
      ).show(context);
    }
  }

  static void showInfo(BuildContext context, dynamic message) {
    if (context.mounted) {
      ElegantNotification.info(
        width: 360,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: const Text('Pesan'),
        description: Text(message.toString()),
        onDismiss: () {},
        onNotificationPressed: () {},
        isDismissable: true,
        dismissDirection: DismissDirection.up,
      ).show(context);
    }
  }
}
