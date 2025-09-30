// BillItem model for the detailed view (if not already defined)
class BillItem {
  final String description;
  final int taka;
  final int hsn;
  final int meter;
  final int rate;
  final double amount;

  BillItem({
    required this.description,
    required this.taka,
    required this.hsn,
    required this.meter,
    required this.rate,
    required this.amount,
  });
}