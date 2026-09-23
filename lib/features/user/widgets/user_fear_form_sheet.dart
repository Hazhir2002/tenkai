import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_controls.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/molecules/tenkai_molecules.dart';

Future<void> showUserFearFormSheet(
  BuildContext context,
  WidgetRef ref,
  //   {
  //   UserFearView? editing,
  // }
) {
  // final notifier = ref.read(userFearFormProvider.notifier)

  return showTenkaiSheet<void>(
    context: context,
    title: 'New fear',
    child: _UserFearFormSheet(),
  );
}

class _UserFearFormSheet extends ConsumerStatefulWidget {
  const _UserFearFormSheet();

  @override
  ConsumerState<_UserFearFormSheet> createState() => _UserFearFormSheetState();
}

class _UserFearFormSheetState extends ConsumerState<_UserFearFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext contex) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TenkaiTextFormField(
                label: 'Title',
                placeholder: 'e.g. Busy places',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
