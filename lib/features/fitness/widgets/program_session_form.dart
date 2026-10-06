import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';

class ProgramSessionForm extends ConsumerStatefulWidget {
  final int programId;

  const ProgramSessionForm({super.key, required this.programId});

  @override
  ConsumerState<ProgramSessionForm> createState() => _ProgramSessionFormState();
}

class _ProgramSessionFormState extends ConsumerState<ProgramSessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? title;
  int? dayOfWeek;
  TimeOfDay? timeOfDay;
  final timeController = TextEditingController();

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: TenkaiSpacing.md,
          children: [
            TenkaiTextFormField(
              isRequired: true,
              label: 'Title',
              placeholder: 'e.g. Leg day',
              onSaved: (value) => title = value,
            ),
            SegmentedButton<int>(
              showSelectedIcon: false,
              emptySelectionAllowed: true,
              segments: const [
                ButtonSegment(value: 1, label: Text('M')),
                ButtonSegment(value: 2, label: Text('T')),
                ButtonSegment(value: 3, label: Text('W')),
                ButtonSegment(value: 4, label: Text('T')),
                ButtonSegment(value: 5, label: Text('F')),
                ButtonSegment(value: 6, label: Text('S')),
                ButtonSegment(value: 7, label: Text('S')),
              ],
              selected: {if (dayOfWeek != null) dayOfWeek!},
              onSelectionChanged: (s) => setState(() => dayOfWeek = s.first),
            ),
            TenkaiTextFormField(
              label: 'Time',
              readOnly: true,
              controller: timeController,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                      timeOfDay ?? const TimeOfDay(hour: 16, minute: 0),
                );
                if (picked != null) {
                  timeOfDay = picked;
                  timeController.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: TenkaiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final programSessions = ref
                      .read(fitnessProvider)
                      .programs!
                      .where((p) => p.id == widget.programId)
                      .first
                      .programSessions;
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref
                        .read(fitnessProvider.notifier)
                        .addProgramSession(
                          ProgramSessionsCompanion(
                            title: Value(title!),
                            programId: Value(widget.programId),
                            timeOfDay: Value(timeOfDay),
                            dayOfWeek: Value(dayOfWeek),
                            hierarchy: Value(
                              programSessions != null
                                  ? programSessions.length
                                  : 0,
                            ),
                          ),
                        );
                  }
                },
                child: Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
