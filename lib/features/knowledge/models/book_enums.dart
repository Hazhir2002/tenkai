/// Which shelf a book is on.
enum BookStatus {
  wantToRead('wantToRead'),
  reading('reading'),
  finished('finished'),
  paused('paused');

  const BookStatus(this.dbValue);

  final String dbValue;

  static BookStatus fromDb(String value) => BookStatus.values.firstWhere(
    (s) => s.dbValue == value,
    orElse: () => BookStatus.reading,
  );

  String get label => switch (this) {
    BookStatus.wantToRead => 'Want to read',
    BookStatus.reading => 'Reading',
    BookStatus.finished => 'Finished',
    BookStatus.paused => 'Paused',
  };
}

/// Whether the reader is on pace toward their deadline / daily goal.
enum PaceState {
  ahead,
  onTrack,
  behind,

  /// No deadline and no daily goal — just tracking progress.
  noTarget,

  /// The book is finished.
  finished;

  String get label => switch (this) {
    PaceState.ahead => 'Ahead',
    PaceState.onTrack => 'On track',
    PaceState.behind => 'Behind',
    PaceState.noTarget => 'No target',
    PaceState.finished => 'Finished',
  };
}
