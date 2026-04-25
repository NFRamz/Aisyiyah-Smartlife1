class ProfileModel {
  String id;
  String role;
  bool full_access;
  String? wilayahId;
  String? daerahId;
  String? cabangId;
  String? rantingId;

  ProfileModel({required this.id, required this.role, required this.full_access, this.wilayahId, this.daerahId, this.cabangId, this.rantingId});
}