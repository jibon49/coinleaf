import 'package:flutter/material.dart';
import '../../data/services/market_price_sync_service.dart';
import '../../dependency_injection.dart';

class MarketPriceSyncWidget extends StatefulWidget {
  final VoidCallback? onSyncComplete;

  const MarketPriceSyncWidget({super.key, this.onSyncComplete});

  @override
  State<MarketPriceSyncWidget> createState() => _MarketPriceSyncWidgetState();
}

class _MarketPriceSyncWidgetState extends State<MarketPriceSyncWidget> {
  final MarketPriceSyncService _syncService = getIt<MarketPriceSyncService>();
  bool _isLoading = false;
  bool _isLoadingPage = false;
  String? _lastSyncText;
  String? _errorMessage;
  SyncResult? _lastResult;
  int _currentPage = 1;
  int _maxPages = 5;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    try {
      final status = await _syncService.getSyncStatus();
      setState(() {
        _lastSyncText = status.lastSyncText;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sync status';
      });
    }
  }

  Future<void> _syncAllPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _syncService.syncAllPrices(maxPages: _maxPages);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
          _showErrorSnackBar(failure.message);
        },
        (syncResult) {
          setState(() {
            _lastResult = syncResult;
            _isLoading = false;
            _lastSyncText = 'Just now';
          });
          _showSuccessSnackBar(syncResult);
          widget.onSyncComplete?.call();
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  Future<void> _syncSpecificPage(int page) async {
    setState(() {
      _isLoadingPage = true;
      _errorMessage = null;
    });

    try {
      final result = await _syncService.syncSpecificPage(page);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoadingPage = false;
          });
          _showErrorSnackBar('Page $page: ${failure.message}');
        },
        (syncResult) {
          setState(() {
            _isLoadingPage = false;
            _lastSyncText = 'Just now';
          });
          _showSuccessSnackBar(syncResult, pageInfo: 'Page $page');
          widget.onSyncComplete?.call();
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Page sync error: $e';
        _isLoadingPage = false;
      });
      _showErrorSnackBar('Page sync failed');
    }
  }

  void _showSuccessSnackBar(SyncResult result, {String? pageInfo}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ ${pageInfo ?? 'Prices synced'} successfully!'),
            Text(result.summary, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.api, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Shwapno API Sync',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE API',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sync Status
          if (_lastSyncText != null)
            Text(
              'Last sync: $_lastSyncText',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_lastResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Sync Results:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text('📦 Fetched: ${_lastResult!.totalFetched}', style: const TextStyle(fontSize: 11)),
                  Text('🆕 New: ${_lastResult!.newItems}', style: const TextStyle(fontSize: 11)),
                  Text('🔄 Updated: ${_lastResult!.updatedItems}', style: const TextStyle(fontSize: 11)),
                  Text('📄 Pages: ${_lastResult!.pagesProcessed}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Full Sync Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _syncAllPrices,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download),
              label: Text(_isLoading ? 'Syncing $_maxPages pages...' : 'Sync All ($_maxPages pages)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Pagination Controls
          Row(
            children: [
              Text(
                'Quick Page Sync:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      final pageNum = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 40,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: _isLoadingPage ? null : () => _syncSpecificPage(pageNum),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.grey[700],
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: _isLoadingPage
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text('$pageNum', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Pages Control
          Row(
            children: [
              Text(
                'Max pages to sync:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _maxPages,
                items: [1, 2, 3, 5, 10].map((pages) =>
                  DropdownMenuItem(value: pages, child: Text('$pages'))
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _maxPages = value);
                  }
                },
                style: Theme.of(context).textTheme.bodySmall,
                underline: Container(height: 1, color: Colors.grey[300]),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Info Text
          Text(
            'Fetches live prices directly from Shwapno.com API with real product data and pricing',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
