import 'package:home_widget/home_widget.dart';

const appGroupId = 'group.com.yourcompany.tenkai';

Future<void> initWidget() async {
  await HomeWidget.setAppGroupId(appGroupId);
}

Future<void> updateWidget(String title, int streak) async {
  await HomeWidget.saveWidgetData<String>('title', title);
  await HomeWidget.saveWidgetData<int>('streak', streak);
  await HomeWidget.updateWidget(
    iOSName: 'TenkaiWidget',
  ); // must match the widget's `kind`
}
