import 'package:equatable/equatable.dart';

abstract class MarketPriceEvent extends Equatable {
  const MarketPriceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllMarketPrices extends MarketPriceEvent {}

class LoadMarketPricesByCategory extends MarketPriceEvent {
  final String category;

  const LoadMarketPricesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SyncMarketPricesEvent extends MarketPriceEvent {}

class RefreshMarketPrices extends MarketPriceEvent {}
