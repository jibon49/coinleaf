import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/market_price/market_price_bloc.dart';
import '../bloc/market_price/market_price_state.dart';
import '../bloc/market_price/market_price_event.dart';
import '../widgets/market_price_sync_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart' as AppUtils;

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  @override
  void initState() {
    super.initState();
    context.read<MarketPriceBloc>().add(LoadAllMarketPrices());
  }

  void _syncPrices() {
    context.read<MarketPriceBloc>().add(SyncMarketPricesEvent());
  }

  void _refreshPrices() {
    context.read<MarketPriceBloc>().add(RefreshMarketPrices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Market Prices'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _refreshPrices,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price Sync Widget
                MarketPriceSyncWidget(
                  onSyncComplete: () {
                    // Refresh the market prices when sync completes
                    context.read<MarketPriceBloc>().add(LoadAllMarketPrices());
                  },
                ),
                const SizedBox(height: 20),

                // Market Prices List
                BlocConsumer<MarketPriceBloc, MarketPriceState>(
                  listener: (context, state) {
                    if (state is MarketPriceSyncSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Prices synced successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is MarketPriceError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is MarketPriceLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is MarketPriceLoaded) {
                      if (state.prices.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Market Prices',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Group prices by category
                          ..._buildPriceGroups(state.prices),
                        ],
                      );
                    }

                    if (state is MarketPriceError) {
                      return _buildErrorState(state.message);
                    }

                    return _buildEmptyState();
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Market Prices Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Sync Prices from Shwapno" above to fetch live market prices',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            'Error Loading Prices',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPriceGroups(List prices) {
    // Group prices by category
    final Map<String, List> groupedPrices = {};

    for (final price in prices) {
      final category = _getCategoryFromItemName(price.itemName);
      if (!groupedPrices.containsKey(category)) {
        groupedPrices[category] = [];
      }
      groupedPrices[category]!.add(price);
    }

    final List<Widget> widgets = [];

    for (final entry in groupedPrices.entries) {
      widgets.add(_buildCategorySection(entry.key, entry.value));
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  String _getCategoryFromItemName(String itemName) {
    final lowerName = itemName.toLowerCase();

    if (lowerName.contains('rice') || lowerName.contains('flour')) return 'Rice & Flour';
    if (lowerName.contains('oil') || lowerName.contains('ghee')) return 'Oil & Ghee';
    if (lowerName.contains('vegetable') || lowerName.contains('potato') ||
        lowerName.contains('onion') || lowerName.contains('tomato')) return 'Vegetables';
    if (lowerName.contains('milk') || lowerName.contains('dairy') ||
        lowerName.contains('cheese') || lowerName.contains('butter')) return 'Dairy';
    if (lowerName.contains('egg') || lowerName.contains('meat') ||
        lowerName.contains('fish') || lowerName.contains('chicken')) return 'Protein';

    return 'Others';
  }

  Widget _buildCategorySection(String category, List prices) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(_getCategoryIcon(category), color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${prices.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...prices.map((price) => _buildPriceItem(price)).toList(),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Rice & Flour': return Icons.grain;
      case 'Oil & Ghee': return Icons.opacity;
      case 'Vegetables': return Icons.eco;
      case 'Dairy': return Icons.local_drink;
      case 'Protein': return Icons.egg;
      default: return Icons.shopping_basket;
    }
  }

  Widget _buildPriceItem(dynamic price) {
    final priceChange = price.priceChange ?? 0.0;
    final hasChange = priceChange != 0.0;
    final isIncrease = priceChange > 0;

    return ListTile(
      title: Text(
        price.itemName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${price.source} • ${price.location}'),
          if (hasChange)
            Row(
              children: [
                Icon(
                  isIncrease ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isIncrease ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isIncrease ? '+' : ''}${AppUtils.CurrencyUtils.formatCurrency(priceChange)}',
                  style: TextStyle(
                    color: isIncrease ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${AppUtils.CurrencyUtils.formatCurrency(price.price)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'per ${price.unit}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
