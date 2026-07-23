// ---------- Generic enum parsing helper ----------

/// Normalizes a string for comparison: lowercase, strip anything
/// that isn't a letter or digit. This lets "Middle Back", "middle_back",
/// "middleBack" and "MiddleBack" all match the same enum.
String _normalizeEnumKey(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Finds the enum value whose name normalizes to match [raw].
/// Returns null if no match (and no fallback is given).
T? _enumFromString<T extends Enum>(List<T> values, dynamic raw, {T? fallback}) {
  if (raw == null) return fallback;
  final key = _normalizeEnumKey(raw.toString());
  for (final v in values) {
    if (_normalizeEnumKey(v.name) == key) return v;
  }
  return fallback;
}

/// Parses a JSON list of strings into a list of enums, skipping
/// (rather than crashing on) any values that don't match.
List<T>? _enumListFromJson<T extends Enum>(List<T> values, dynamic raw) {
  if (raw == null) return null;
  final list = (raw as List)
      .map((e) => _enumFromString<T>(values, e))
      .whereType<T>() // drops nulls (unmatched strings)
      .toList();
  return list;
}

List<String>? _stringListFromJson(dynamic raw) {
  if (raw == null) return null;
  return (raw as List).map((e) => e.toString()).toList();
}

// ---------- Enums ----------

enum MuscleEnum {
  abdominals,
  hamstrings,
  adductors,
  quadriceps,
  biceps,
  shoulders,
  chest,
  middleBack,
  calves,
  glutes,
  lowerBack,
  lats,
  triceps,
  traps,
  forearms,
  neck,
  abductors;

  static MuscleEnum? fromJson(dynamic raw) =>
      _enumFromString(MuscleEnum.values, raw);
}

enum ForceTypeEnum {
  pull,
  push,
  static_;

  static ForceTypeEnum? fromJson(dynamic raw) =>
      _enumFromString(ForceTypeEnum.values, raw);
}

enum LevelTypeEnum {
  beginner,
  intermediate,
  expert;

  static LevelTypeEnum fromJson(dynamic raw) => _enumFromString(
    LevelTypeEnum.values,
    raw,
    fallback: LevelTypeEnum.beginner,
  )!;
}

enum MechanicTypeEnum {
  compound,
  isolation;

  static MechanicTypeEnum? fromJson(dynamic raw) =>
      _enumFromString(MechanicTypeEnum.values, raw);
}

enum EquipmentTypeEnum {
  bodyOnly,
  machine,
  other,
  foamRoll,
  kettlebells,
  dumbbell,
  cable,
  barbell,
  bands,
  medicineBall,
  exerciseBall,
  eZCurlBar;

  static EquipmentTypeEnum fromJson(dynamic raw) => _enumFromString(
    EquipmentTypeEnum.values,
    raw,
    fallback: EquipmentTypeEnum.other,
  )!;
}

enum CategoryTypeEnum {
  strength,
  stretching,
  plyometrics,
  strongman,
  powerlifting,
  cardio,
  olympicWeightlifting;

  static CategoryTypeEnum fromJson(dynamic raw) => _enumFromString(
    CategoryTypeEnum.values,
    raw,
    fallback: CategoryTypeEnum.strength,
  )!;
}

// ---------- Exercise model ----------

class Exercise {
  final String id;
  final String name;
  final List<String>? aliases;
  final List<MuscleEnum>? primaryMuscles;
  final List<MuscleEnum>? secondaryMuscles;
  final ForceTypeEnum? force;
  final LevelTypeEnum level;
  final MechanicTypeEnum? mechanic;
  final EquipmentTypeEnum equipment;
  final CategoryTypeEnum category;
  final List<String>? instructions;
  final String? description;
  final List<String>? tips;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  const Exercise({
    required this.id,
    required this.name,
    this.aliases,
    this.primaryMuscles,
    this.secondaryMuscles,
    this.force,
    required this.level,
    this.mechanic,
    required this.equipment,
    required this.category,
    this.instructions,
    this.description,
    this.tips,
    required this.dateCreated,
    required this.dateUpdated,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      aliases: _stringListFromJson(json['aliases']),
      primaryMuscles: _enumListFromJson(
        MuscleEnum.values,
        json['primaryMuscles'],
      ),
      secondaryMuscles: _enumListFromJson(
        MuscleEnum.values,
        json['secondaryMuscles'],
      ),
      force: ForceTypeEnum.fromJson(json['force']),
      level: LevelTypeEnum.fromJson(json['level']),
      mechanic: MechanicTypeEnum.fromJson(json['mechanic']),
      equipment: EquipmentTypeEnum.fromJson(json['equipment']),
      category: CategoryTypeEnum.fromJson(json['category']),
      instructions: _stringListFromJson(json['instructions']),
      description: json['description'] as String?,
      tips: _stringListFromJson(json['tips']),
      dateCreated: DateTime.parse(json['date_created'] as String),
      dateUpdated: DateTime.parse(json['date_updated'] as String),
    );
  }
}
