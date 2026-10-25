import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tenkai/core/theme/tenkai_semantic_colors.dart';

Future<(int, int)?> pickTime(BuildContext context, int hour, int minute) async {
  var h = hour;
  var m = minute;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.tenkai.card,
    builder: (sheetContext) {
      return CupertinoTheme(
        data: CupertinoThemeData(brightness: Theme.of(context).brightness),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2024, 1, 1, hour, minute),
                  onDateTimeChanged: (dt) {
                    h = dt.hour;
                    m = dt.minute;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    child: Text('Done'),
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return ok == true ? (h, m) : null;
}
