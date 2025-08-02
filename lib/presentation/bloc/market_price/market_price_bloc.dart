import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/market_price_usecases.dart';
import 'market_price_event.dart';
import 'market_price_state.dart';

class MarketPriceBloc extends Bloc<MarketPriceEvent, MarketPriceState> {
  final GetAllMarketPrices getAllMarketPrices;
  final GetMarketPricesByCategory getMarketPricesByCategory;
  final SyncMarketPrices syncMarketPrices;

  MarketPriceBloc({
    required this.getAllMarketPrices,
    required this.getMarketPricesByCategory,
    required this.syncMarketPrices,
  }) : super(MarketPriceInitial()) {
    on<LoadAllMarketPrices>(_onLoadAllMarketPrices);
    on<LoadMarketPricesByCategory>(_onLoadMarketPricesByCategory);
    on<SyncMarketPricesEvent>(_onSyncMarketPrices);
    on<RefreshMarketPrices>(_onRefreshMarketPrices);
  }

  Future<void> _onLoadAllMarketPrices(LoadAllMarketPrices event, Emitter<MarketPriceState> emit) async {
    emit(MarketPriceLoading());

    final result = await getAllMarketPrices();
    result.fold(
      (failure) => emit(MarketPriceError(failure.message)),
      (prices) => emit(MarketPriceLoaded(
        prices: prices,
        lastSyncTime: DateTime.now(),
      )),
    );
  }

  Future<void> _onLoadMarketPricesByCategory(LoadMarketPricesByCategory event, Emitter<MarketPriceState> emit) async {
    emit(MarketPriceLoading());

    final result = await getMarketPricesByCategory(event.category);
    result.fold(
      (failure) => emit(MarketPriceError(failure.message)),
      (prices) => emit(MarketPriceLoaded(
        prices: prices,
        lastSyncTime: DateTime.now(),
      )),
    );
  }

  Future<void> _onSyncMarketPrices(SyncMarketPricesEvent event, Emitter<MarketPriceState> emit) async {
    emit(MarketPriceSyncing());

    final result = await syncMarketPrices();
    result.fold(
      (failure) => emit(MarketPriceError(failure.message)),
      (_) {
        emit(const MarketPriceSyncSuccess('Market prices updated successfully'));
        add(LoadAllMarketPrices());
      },
    );
  }

  Future<void> _onRefreshMarketPrices(RefreshMarketPrices event, Emitter<MarketPriceState> emit) async {
    add(LoadAllMarketPrices());
  }
}
