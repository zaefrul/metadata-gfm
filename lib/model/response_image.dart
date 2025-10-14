class ResponseImage {
  const ResponseImage({
    required this.woTaskUploadId,
    required this.documentFilename,
    required this.documentDesc,
    required this.documentSrc,
  });

  final String woTaskUploadId;
  final String documentFilename;
  final String documentDesc;
  final String documentSrc;

  factory ResponseImage.fromJson(Map<String, dynamic> json) {
    return ResponseImage(
      woTaskUploadId: json['woTaskUploadId']?.toString() ?? '',
      documentFilename: json['documentFilename']?.toString() ?? '',
      documentDesc: json['documentDesc']?.toString() ?? '',
      documentSrc: json['documentSrc']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'woTaskUploadId': woTaskUploadId,
      'documentFilename': documentFilename,
      'documentDesc': documentDesc,
      'documentSrc': documentSrc,
    };
  }
}
