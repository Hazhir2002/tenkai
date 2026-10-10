import 'package:drift/src/runtime/data_class.dart';
import 'package:tenkai/core/database.dart';

class HabitModel extends Habit {
  HabitModel({
    required super.id,
    required super.title,
    super.description,
    super.cueHabitId,
    required super.status,
    required super.reminderEnabled,
    required super.cueType,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HabitModel.fromHabit(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      status: habit.status,
      reminderEnabled: habit.reminderEnabled,
      cueType: habit.cueType,
      sortOrder: habit.sortOrder,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
    );
  }

  @override
  Habit copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    Value<String?> description = const Value.absent(),
    String? status,
    String? cueType,
    Value<int?> cueHabitId = const Value.absent(),
    bool? reminderEnabled,
    int? sortOrder,
  }) {
    return HabitModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description.value ?? this.description,
      status: status ?? this.status,
      cueType: cueType ?? this.cueType,
      cueHabitId: cueHabitId.value ?? this.cueHabitId,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
