import 'package:equatable/equatable.dart';

import 'time_window.dart';

class Stylist extends Equatable {
  const Stylist({
    required this.id,
    required this.salonId,
    required this.name,
    required this.title,
    required this.bio,
    required this.photoUrl,
    required this.specialties,
    required this.workingHours,
    this.bufferMinutes = 15,
  });

  final String id;
  final String salonId;
  final String name;
  final String title;
  final String bio;
  final String photoUrl;
  final List<String> specialties;
  final WorkingHours workingHours;
  final int bufferMinutes;

  @override
  List<Object?> get props => [
    id,
    salonId,
    name,
    title,
    bio,
    photoUrl,
    specialties,
    workingHours,
    bufferMinutes,
  ];
}
