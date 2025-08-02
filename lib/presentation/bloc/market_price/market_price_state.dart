import 'package:equatable/equatable.dart';
import '../../../domain/entities/market_price.dart';

abstract class MarketPriceState extends Equatable {
  const MarketPriceState();

  @override
  List<Object?> get props => [];
}

class MarketPriceInitial extends MarketPriceState {}

class MarketPriceLoading extends MarketPriceState {}

class MarketPriceLoaded extends MarketPriceState {
  final List<MarketPrice> prices;
  final DateTime lastSyncTime;

  const MarketPriceLoaded({
    required this.prices,
    required this.lastSyncTime,
  });

  @override
  List<Object?> get props => [prices, lastSyncTime];
}

class MarketPriceSyncing extends MarketPriceState {}

class MarketPriceSyncSuccess extends MarketPriceState {
  final String message;

  const MarketPriceSyncSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketPriceError extends MarketPriceState {
  final String message;

  const MarketPriceError(this.message);

  @override
  List<Object?> get props => [message];
}
