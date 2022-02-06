class ExecutionModel {
  final String max;
  final String min;
  final bool exceed;
  final String current;
  final String execute;
  final String assignTime;
  final String responseTimeDue;
  final String completionTimeDue;
  final String responseTimeSla;
  final String completionTimeSla;
  final bool completionTimeExceeded;
  final bool responseTimeExceeded;

  ExecutionModel(
    this.max,
    this.min,
    this.exceed,
    this.current,
    this.execute,
    this.assignTime,
    this.responseTimeDue,
    this.completionTimeDue,
    this.responseTimeSla,
    this.completionTimeSla,
    this.completionTimeExceeded,
    this.responseTimeExceeded,
  );

  factory ExecutionModel.fromJson(Map<String, dynamic> json) {
    return ExecutionModel(
      json["maxExecutionTime"] ?? "-",
      json["minExecutionTime"] ?? "-",
      json["isTimeExceeded"] ?? false,
      json["currentTime"] ?? "-",
      json["executeTime"] ?? "-",
      json["assignTime"] ?? "-",
      json["responseTimeDue"] ?? "-",
      json["completionTimeDue"] ?? "-",
      json["responseTimeSla"] ?? "-",
      json["completionTimeSla"] ?? "-",
      json["completionTimeExceeded"] ?? false,
      json["responseTimeExceeded"] ?? false,
    );
  }
}
