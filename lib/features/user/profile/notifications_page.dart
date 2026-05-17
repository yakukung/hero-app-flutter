import 'package:flutter/material.dart';

import 'package:hero_app_flutter/core/models/notification_model.dart';
import 'package:hero_app_flutter/core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<AppNotificationModel> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final result = await NotificationService.fetchNotifications();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _notifications = result.data ?? const [];
      _errorMessage = result.success ? '' : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 160),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(
            child: Text(
              'ยังไม่มีการแจ้งเตือน',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return ListTile(
          leading: Icon(
            item.isRead ? Icons.notifications_none : Icons.notifications_active,
          ),
          title: Text(item.title),
          subtitle: Text(item.message),
          onTap: () => NotificationService.markAsRead(item.id),
        );
      },
    );
  }
}
