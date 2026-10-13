import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/widgets/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/user/provider/user_fear_provider.dart';

Future<void> showUserFearFormSheet(
  BuildContext context,
  WidgetRef ref,
  //   {
  //   UserFearView? editing,
  // }
) {
  // final notifier = ref.read(userFearFormProvider.notifier)

  return showModalBottomSheet<void>(
    context: context,
    // title: 'New fear',
    builder: (context) => _UserFearFormSheet(),
  );
}

class _UserFearFormSheet extends ConsumerStatefulWidget {
  const _UserFearFormSheet();

  @override
  ConsumerState<_UserFearFormSheet> createState() => _UserFearFormSheetState();
}

class _UserFearFormSheetState extends ConsumerState<_UserFearFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? title;
  String? description;
  String? why;
  String? solution;

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
            spacing: TenkaiSpacing.md,
            children: [
              TenkaiTextFormField(
                isRequired: true,
                label: 'Title',
                placeholder: 'e.g. Busy places',
                onSaved: (value) => title = value,
              ),
              TenkaiTextFormField(
                label: 'Description',
                placeholder: 'e.g. when there are too many people',
                maxLines: 3,
                onSaved: (value) => description = value,
              ),
              TenkaiTextFormField(
                label: 'Why',
                isRequired: true,
                placeholder: 'e.g. I feel like everybody is looking at me',
                onSaved: (value) => why = value,
              ),
              TenkaiTextFormField(
                label: 'Solution',
                placeholder: 'e.g. Try to be in public places more',
                onSaved: (value) => solution = value,
              ),
              const SizedBox(height: TenkaiSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // ref.read(userFearProvider.notifier).addFear(entry);
                    }
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
