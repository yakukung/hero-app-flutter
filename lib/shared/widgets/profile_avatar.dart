import 'package:flutter/material.dart';
import 'package:hero_app_flutter/core/config/api_connect.dart' as api_connect;

class ProfileAvatar extends StatelessWidget {
  final String uid;
  final String? username;
  final String? imageUrl;
  final double size;
  final String? apiEndpoint;

  const ProfileAvatar({
    super.key,
    required this.uid,
    this.username,
    this.imageUrl,
    this.size = 40,
    this.apiEndpoint,
  });

  String get _initials {
    final name = username?.trim();
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
  }

  Color get _backgroundColor {
    final hash = uid.hashCode;
    final hue = (hash & 0xFF).toDouble();
    return HSVColor.fromAHSV(1, hue, 0.45, 0.55).toColor();
  }

  String get _resolvedUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    final base = apiEndpoint ?? api_connect.apiEndpoint;
    return '$base/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;

    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey[200],
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _backgroundColor,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
