/// The app's source of "now".
///
/// Domain rules take time as an input rather than reading the system clock, so
/// every scheduling and escalation rule is testable at any instant without
/// waiting for one.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
