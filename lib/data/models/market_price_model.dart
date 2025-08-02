import '../../domain/entities/market_price.dart';

class MarketPriceModel extends MarketPrice {
  const MarketPriceModel({
    required super.id,
    required super.itemName,
    required super.price,
    required super.unit,
    required super.location,
    required super.lastUpdated,
    required super.source,
    super.previousPrice,
    super.priceChange,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      source: json['source'] as String,
      previousPrice: (json['previous_price'] as num?)?.toDouble(),
      priceChange: (json['price_change'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'price': price,
      'unit': unit,
      'location': location,
      'last_updated': lastUpdated.toIso8601String(),
      'source': source,
      'previous_price': previousPrice,
      'price_change': priceChange,
    };
  }

  factory MarketPriceModel.fromEntity(MarketPrice marketPrice) {
    return MarketPriceModel(
      id: marketPrice.id,
      itemName: marketPrice.itemName,
      price: marketPrice.price,
      unit: marketPrice.unit,
      location: marketPrice.location,
      lastUpdated: marketPrice.lastUpdated,
      source: marketPrice.source,
      previousPrice: marketPrice.previousPrice,
      priceChange: marketPrice.priceChange,
    );
  }
}
