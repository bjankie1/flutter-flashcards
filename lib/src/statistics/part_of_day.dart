enum PartOfDay {
  morning(8),
  afternoon(12),
  evening(18),
  night(24);

  final int lastHour;
  const PartOfDay(this.lastHour);

  static PartOfDay fromHour(int hour) =>
      PartOfDay.values.firstWhere((p) => p.lastHour >= hour);
}
