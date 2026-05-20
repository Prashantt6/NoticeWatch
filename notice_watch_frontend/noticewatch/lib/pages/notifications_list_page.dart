import 'package:flutter/material.dart';
import 'package:noticewatch/notice_refresh_hub.dart';
import 'package:noticewatch/notification_card.dart';
import 'package:noticewatch/notice.dart';
import 'package:noticewatch/repository.dart';

const Color _scaffoldBg = Color(0xFF0F172A);
const Color _cardBg = Color(0xFF1E293B);
const Color _borderMuted = Color(0xFF334155);

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notice>? notices;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  final NoticeService _service = NoticeService();

  List<Notice> _noticesMatchingSearch() {
    final list = notices;
    if (list == null) return [];
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List<Notice>.from(list);
    return list.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  List<Notice> _mapNotices(List<dynamic> raw) {
    return raw.map<Notice>((e) {
      return Notice(
        title: e['title']?.toString() ?? '',
        publishedDate: e['published_date']?.toString() ?? '',
        pdfLink: e['pdf_link']?.toString() ?? '',
      );
    }).toList();
  }

  void _applyNotices(List<Notice> list) {
    if (!mounted) return;
    setState(() {
      notices = list;
      _isLoading = false;
      _error = null;
    });
  }

  /// Load from disk only (no API).
  Future<void> _loadFromCache() async {
    final cached = await _service.loadCachedNotices();
    if (cached == null) return;
    _applyNotices(_mapNotices(cached));
  }

  /// [fromNetwork] true → call API, update UI, save cache.
  /// false → use cache if present; otherwise fetch (first install).
  Future<void> loadNotices({required bool fromNetwork}) async {
    if (fromNetwork) {
      setState(() {
        _isLoading = notices == null;
        _error = null;
      });

      try {
        final remote = await _service.getData();
        await _service.saveNoticesCache(remote);
        _applyNotices(_mapNotices(remote));
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Failed to load notices. Pull down to retry.';
        });
        debugPrint('Error loading notices: $e');
      }
      return;
    }

    final hasCache = await _service.hasNoticesCache();
    if (hasCache) {
      await _loadFromCache();
      return;
    }

    await loadNotices(fromNetwork: true);
  }

  @override
  void dispose() {
    NoticeRefreshHub.instance.removeListener(_onRefreshRequested);
    _searchController.dispose();
    super.dispose();
  }

  /// FCM handler already fetched and saved cache; reload UI from disk only.
  void _onRefreshRequested() {
    _loadFromCache();
  }

  @override
  void initState() {
    super.initState();
    NoticeRefreshHub.instance.addListener(_onRefreshRequested);
    loadNotices(fromNetwork: false);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 14,
            height: 1.2,
          ),
          cursorColor: Colors.amber,
          decoration: InputDecoration(
            hintText: 'Search notices…',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
            filled: true,
            fillColor: _cardBg,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Icon(
                Icons.search_rounded,
                size: 18,
                color: Colors.amber[400],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: _searchController.text.trim().isEmpty
                ? null
                : IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Clear',
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderMuted, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.amber.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentSlivers(List<Notice> filtered) {
    if (_isLoading && notices == null) {
      return const [
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (notices == null || notices!.isEmpty) {
      return [
        _emptyState(
          icon: Icons.notifications_off_outlined,
          message: _error ?? 'No notices yet. Pull down to refresh.',
        ),
      ];
    }

    return [
      SliverToBoxAdapter(child: _buildSearchBar()),
      if (filtered.isEmpty)
        _emptyState(
          icon: Icons.search_off_outlined,
          message: 'No notices match your search.',
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return NotificationCard(details: filtered[index]);
            },
            childCount: filtered.length,
          ),
        ),
      const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _noticesMatchingSearch();

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'NoticeWatch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.amber,
        backgroundColor: _cardBg,
        displacement: 48,
        onRefresh: () => loadNotices(fromNetwork: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: _buildContentSlivers(filtered),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadNotices(fromNetwork: true),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
