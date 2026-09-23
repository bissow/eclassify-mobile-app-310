import 'dart:ui';

enum ItemStatus {
  review('review', 'review', Color(0xff0C5D9C)),
  approved('approved', 'approved', Color(0xFF02AD11)),
  softRejected('soft rejected', 'softRejected', Color(0xffEA0707)),
  permanentRejected(
    'permanent rejected',
    'permanent_rejected',
    Color(0xffEA0707),
  ),
  soldOut('sold out', 'soldOut', Color(0xFFFB9D22)),
  expired('expired', 'expired', Color(0xffFE0000)),
  inactive('inactive', 'inactive', Color(0xffFE0000)),
  active('active', 'active', Color(0xff0C5D9C)),
  resubmitted('resubmitted', 'resubmitted', Color(0xff0C5D9C)),
  unknown('unknown', 'unknown', Color(0xff9e9a9a));

  const ItemStatus(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  static ItemStatus parse(String value) {
    return ItemStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => ItemStatus.unknown,
    );
  }
}
