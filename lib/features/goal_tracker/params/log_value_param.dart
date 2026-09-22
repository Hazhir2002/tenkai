/// Payload for `POST /goals/{id}/logs` — records a new value. [note] optional.
class LogValueParam {
  final double value;
  final String? note;

  const LogValueParam({required this.value, this.note});

  Map<String, dynamic> toJson() => {
    'value': value,
    if (note != null && note!.isNotEmpty) 'note': note,
  };
}
