import 'crop_master.dart';

class UserCrop {
  final String id;
  final CropMaster crop;
  final DateTime sowingDate;
  final double latitude;
  final double longitude;
  final String locationLabel;

  UserCrop({
    required this.id,
    required this.crop,
    required this.sowingDate,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
  });
}
