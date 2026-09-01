/// The avatar a person picks for their local profile (PRD §8.2, ADR-010).
///
/// Deliberately a closed set of glyphs rather than a photo picker: an avatar
/// here is a greeting, not an identity document, and a fixed set means the
/// profile stays a handful of bytes in the preferences table with no image
/// file, no storage permission and nothing to leak.
///
/// [id] is the stored value and must never change — it is written to the
/// device's store. The icon and colour for each live in the presentation layer,
/// because `domain/` knows nothing about Flutter (PRD §5.3).
enum ProfileAvatar {
  beaver('beaver', 'Beaver'),
  sprout('sprout', 'Sprout'),
  moon('moon', 'Moon'),
  paperPlane('plane', 'Paper plane'),
  coffee('coffee', 'Coffee'),
  spark('spark', 'Spark');

  const ProfileAvatar(this.id, this.label);

  /// The stored identifier. Stable across releases.
  final String id;

  /// The accessible name, read out by a screen reader.
  final String label;

  static const ProfileAvatar fallback = ProfileAvatar.beaver;

  /// Resolves a stored [id], falling back rather than throwing: an unknown
  /// value means a downgrade or a hand-edited row, and neither is worth
  /// blocking someone from their own promises.
  static ProfileAvatar fromId(String? id) {
    if (id == null) return fallback;
    for (final avatar in ProfileAvatar.values) {
      if (avatar.id == id) return avatar;
    }
    return fallback;
  }
}
