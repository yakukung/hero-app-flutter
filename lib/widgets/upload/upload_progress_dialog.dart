import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/upload_state.dart';

/// Upload progress dialog widget with premium design
class UploadProgressDialog extends StatelessWidget {
  final UploadState state;
  final VoidCallback onClose;

  const UploadProgressDialog({
    super.key,
    required this.state,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isUploading) {
      return _buildUploadingView();
    } else if (state.isSuccess) {
      return _buildSuccessView();
    } else {
      return _buildErrorView();
    }
  }

  Widget _buildUploadingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated upload icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF2A5DB9).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: Color(0xFF2A5DB9),
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'กำลังอัปโหลด...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'กรุณารอสักครู่',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
        const SizedBox(height: 24),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A5DB9)),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${(state.progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A5DB9),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon with background
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'อัปโหลดสำเร็จ!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ชีตของคุณถูกอัปโหลดเรียบร้อยแล้ว',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'เสร็จสิ้น',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error icon with background
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_rounded, color: Colors.red, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          'อัปโหลดไม่สำเร็จ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'ปิด',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows the upload progress dialog
  static void show({
    required BuildContext context,
    required ValueNotifier<UploadState> stateNotifier,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<UploadState>(
              valueListenable: stateNotifier,
              builder: (context, state, child) {
                return UploadProgressDialog(
                  state: state,
                  onClose: () => Navigator.pop(dialogContext),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
