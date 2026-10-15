import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_colors.dart';

class SystemMessagesPage extends StatefulWidget {
  const SystemMessagesPage({super.key});

  @override
  State<SystemMessagesPage> createState() => _SystemMessagesPageState();
}

class _SystemMessagesPageState extends State<SystemMessagesPage> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSystemMessages();
  }

  Future<void> _fetchSystemMessages() async {
    try {
      final response = await SupabaseConfig.client
          .from('system_messages')
          .select()
          .order('created_at', ascending: true);
      if (response.isNotEmpty) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('SystemMessages fetch error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gemEmerald, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'System Messages',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gemEmerald))
          : _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: AppColors.gemEmerald.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No system messages yet',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildDynamicMessageCard(msg);
                  },
                ),
    );
  }

  Widget _buildDynamicMessageCard(Map<String, dynamic> msg) {
    final title = msg['title']?.toString() ?? 'Notice';
    final content = msg['content']?.toString() ?? '';
    final createdAt = msg['created_at']?.toString() ?? '';
    String timeStr = 'Recent';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        timeStr = '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Center(
            child: Text(
              timeStr,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBellAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        content,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBellAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFD1FAE5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.notifications,
          color: Color(0xFF10B981),
          size: 20,
        ),
      ),
    );
  }
}
