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
  String fileUploadName = "";

  UploadH({this.ppmTaskId, this.uploadType, this.longitude, this.latitude, this.fileUploadName, this.fileUploadFilename, this.fileUploadType, this.fileUploadData, this.fileUploadSize});

  dynamic get toJson{
    return {
      "action" : action,
      "ppmTaskId" : ppmTaskId,
      "uploadType" : uploadType,
      "longitude" : longitude,
      "latitude" : latitude,
      "fileUpload[name]" : fileUploadName,
      "fileUpload[filename]" : fileUploadFilename,
      "fileUpload[size]" : fileUploadSize,
      "fileUpload[type]" : fileUploadType,
      "fileUpload[data]" : fileUploadData
    };
  }
}