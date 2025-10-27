import 'package:GEMS/model/complaint.dart';

class MaterialAddArguments {
  const MaterialAddArguments({
    required this.workOrderId,
  });

  final String workOrderId;
}

class MaterialEditArguments {
  const MaterialEditArguments({
    required this.workOrderId,
    required this.material,
  });

  final String workOrderId;
  final ComplaintD material;
}
