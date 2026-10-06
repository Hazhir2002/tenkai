import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/design_system/atoms/tenkai_text_form_field.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/providers/fitness_provider.dart';

class SessionExerciseForm extends ConsumerStatefulWidget {
  final int programId;
  final int programSessionId;

  const SessionExerciseForm({
    super.key,
    required this.programId,
    required this.programSessionId,
  });

  @override
  ConsumerState<SessionExerciseForm> createState() =>
      _SessionExerciseFormState();
}

class _SessionExerciseFormState extends ConsumerState<SessionExerciseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? title;
  int? sets;
  int? repsStart;
  int? repsEnd;
  int? durationSec;

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
              textInputAction: TextInputAction.next,
              placeholder: 'e.g. Gym Program',
              onSaved: (value) => title = value,
            ),
            TenkaiTextFormField(
              isRequired: true,
              label: 'Sets',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              placeholder: 'e.g. 4',
              onSaved: (value) => sets = int.parse(value!),
            ),
            TenkaiTextFormField(
              label: 'From Reps',
              placeholder: 'e.g. 8',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onSaved: (value) =>
                  repsStart = value != null ? int.tryParse(value) : null,
            ),
            TenkaiTextFormField(
              label: 'To Reps',
              placeholder: 'e.g. 12',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onSaved: (value) =>
                  repsEnd = value != null ? int.tryParse(value) : null,
            ),
            TenkaiTextFormField(
              label: 'Duration (sec)',
              placeholder: 'e.g. 60',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSaved: (value) =>
                  durationSec = value != null ? int.tryParse(value) : null,
            ),

            const SizedBox(height: TenkaiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final sessionExercises = ref
                        .read(fitnessProvider)
                        .programs!
                        .where((p) => p.id == widget.programId)
                        .first
                        .programSessions!
                        .where((ps) => ps.id == widget.programSessionId)
                        .first
                        .sessionExercises;
                    ref
                        .read(fitnessProvider.notifier)
                        .addSessionExercise(
                          widget.programId,
                          SessionExercisesCompanion(
                            title: Value(title!),
                            sets: Value(sets!),
                            repsStart: Value(repsStart),
                            repsEnd: Value(repsEnd),
                            durationSec: Value(durationSec),
                            sessionId: Value(widget.programSessionId),
                            hierarchy: Value(
                              sessionExercises != null
                                  ? sessionExercises.length
                                  : 0,
                            ),
                          ),
                        );
                  }
                },
                child: Text("Create"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
