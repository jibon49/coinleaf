import 'package:equatable/equatable.dart';

class MarketPrice extends Equatable {
  final String id;
  final String itemName;
  final double price;
  final String unit;
  final String location;
  final DateTime lastUpdated;
  final String source;
  final double? previousPrice;
  final double? priceChange;

  const MarketPrice({
    required this.id,
    required this.itemName,
    required this.price,
    required this.unit,
    required this.location,
    required this.lastUpdated,
    required this.source,
    this.previousPrice,
    this.priceChange,
  });

  double get priceChangePercentage {
    if (previousPrice == null || previousPrice == 0) return 0.0;
    return ((price - previousPrice!) / previousPrice!) * 100;
  }

  bool get isPriceIncreased => priceChangePercentage > 0;
  bool get isPriceDecreased => priceChangePercentage < 0;

  MarketPrice copyWith({
    String? id,
    String? itemName,
    double? price,
    String? unit,
    String? location,
    DateTime? lastUpdated,
    String? source,
    double? previousPrice,
    double? priceChange,
  }) {
    return MarketPrice(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      source: source ?? this.source,
      previousPrice: previousPrice ?? this.previousPrice,
      priceChange: priceChange ?? this.priceChange,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemName,
        price,
        unit,
        location,
        lastUpdated,
        source,
        previousPrice,
        priceChange,
      ];
}
