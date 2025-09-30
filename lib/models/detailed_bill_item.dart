class DetailedBillItem {
  final String description;
  final int taka;
  final int hsn;
  final int meter;
  final int rate;
  final double amount;

  DetailedBillItem({
    required this.description,
    required this.taka,
    required this.hsn,
    required this.meter,
    required this.rate,
    required this.amount,
  });

  DetailedBillItem copyWith({
    String? description,
    int? taka,
    int? hsn,
    int? meter,
    int? rate,
    double? amount,
  }) {
    return DetailedBillItem(
      description: description ?? this.description,
      taka: taka ?? this.taka,
      hsn: hsn ?? this.hsn,
      meter: meter ?? this.meter,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }
}
