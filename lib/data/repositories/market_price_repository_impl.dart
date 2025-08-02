import 'package:dartz/dartz.dart';
import '../../domain/entities/market_price.dart';
import '../../domain/repositories/market_price_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/market_price_local_data_source.dart';
import '../models/market_price_model.dart';

class MarketPriceRepositoryImpl implements MarketPriceRepository {
  final MarketPriceLocalDataSource localDataSource;

  MarketPriceRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<MarketPrice>>> getAllMarketPrices() async {
    try {
      final prices = await localDataSource.getAllMarketPrices();
      return Right(prices);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MarketPrice>>> getMarketPricesByCategory(String category) async {
    try {
      final prices = await localDataSource.getMarketPricesByCategory(category);
      return Right(prices);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MarketPrice>> getMarketPriceById(String id) async {
    try {
      final price = await localDataSource.getMarketPriceById(id);
      return Right(price);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MarketPrice>> getMarketPriceByItem(String itemName) async {
    try {
      final price = await localDataSource.getMarketPriceByItem(itemName);
      return Right(price);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMarketPrice(MarketPrice marketPrice) async {
    try {
      final priceModel = MarketPriceModel.fromEntity(marketPrice);
      await localDataSource.updateMarketPrice(priceModel);
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncMarketPrices() async {
    try {
      // In a real app, this would fetch from an API
      // For now, we'll simulate a sync with updated prices
      final mockUpdatedPrices = [
        MarketPriceModel(
          id: 'rice_001',
          itemName: 'Rice',
          price: 2.55,
          unit: 'kg',
          location: 'Local Market',
          lastUpdated: DateTime.now(),
          source: 'API',
          previousPrice: 2.50,
          priceChange: 0.05,
        ),
        MarketPriceModel(
          id: 'oil_001',
          itemName: 'Cooking Oil',
          price: 4.30,
          unit: 'liter',
          location: 'Local Market',
          lastUpdated: DateTime.now(),
          source: 'API',
          previousPrice: 4.20,
          priceChange: 0.10,
        ),
      ];

      await localDataSource.insertMarketPrices(mockUpdatedPrices);
      await localDataSource.setLastSyncTime(DateTime.now());
      return const Right(null);
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getLastSyncTime() async {
    try {
      final lastSync = await localDataSource.getLastSyncTime();
      return Right(lastSync ?? DateTime.now().subtract(const Duration(days: 1)));
    } on DatabaseFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }
}
