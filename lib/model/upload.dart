class UploadH {
  final String action = "upload_maintenance_image";
  final String ppmTaskId;
  final String uploadType;
  final String longitude;
  final String latitude;
  final String fileUploadFilename;
  final String fileUploadSize;
  final String fileUploadType;
  final String fileUploadData;
  String fileUploadName;

  UploadH({
    required this.ppmTaskId,
    required this.uploadType,
    required this.longitude,
    required this.latitude,
    required this.fileUploadFilename,
    required this.fileUploadSize,
    required this.fileUploadType,
    required this.fileUploadData,
    this.fileUploadName = "",
  });

  dynamic get toJson {
    return {
      "action": action,
      "ppmTaskId": ppmTaskId,
      "uploadType": uploadType,
      "longitude": longitude,
      "latitude": latitude,
      "fileUpload[name]": fileUploadName,
      "fileUpload[filename]": fileUploadFilename,
      "fileUpload[size]": fileUploadSize,
      "fileUpload[type]": fileUploadType,
      "fileUpload[data]": fileUploadData,
    };
  }
}