/// Manual categories for V1 (PRD §6.4).
///
/// A short, fixed list on purpose: the product's job is to make "later" cheap,
/// and free-form tagging turns every capture into a filing decision.
/// Auto-categorization arrives later through enrichment (§5.5) and will assign
/// these same values — which is why the [wire] strings are part of the stored
/// contract rather than display text.
enum PromiseCategory {
  reply('reply', 'Reply'),
  read('read', 'Read'),
  watch('watch', 'Watch'),
  buy('buy', 'Buy'),
  work('work', 'Work'),
  errand('errand', 'Errand'),
  idea('idea', 'Idea');

  const PromiseCategory(this.wire, this.label);

  /// Stored in `intentions.category`.
  final String wire;

  /// User-facing text.
  final String label;

  static PromiseCategory? fromWire(String? value) {
    if (value == null) return null;
    for (final category in PromiseCategory.values) {
      if (category.wire == value) return category;
    }
    // An unknown value can only come from a newer build or enrichment; showing
    // nothing beats showing a wrong label.
    return null;
  }
}
