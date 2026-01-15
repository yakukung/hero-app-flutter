/// Upload state model for tracking upload progress
class UploadState {
  final double progress;
  final bool isUploading;
  final bool isSuccess;
  final String? errorMessage;

  const UploadState({
    this.progress = 0.0,
    this.isUploading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  UploadState copyWith({
    double? progress,
    bool? isUploading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return UploadState(
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
