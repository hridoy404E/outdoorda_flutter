class InstallerServiceAreaOption {
  final int id;
  final String name;

  const InstallerServiceAreaOption({required this.id, required this.name});

  factory InstallerServiceAreaOption.fromAvailableJson(
    Map<String, dynamic> json,
  ) {
    return InstallerServiceAreaOption(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  factory InstallerServiceAreaOption.fromAssignedJson(
    Map<String, dynamic> json,
  ) {
    return InstallerServiceAreaOption(
      id: json['area_id'] is int
          ? json['area_id'] as int
          : int.tryParse(json['area_id']?.toString() ?? '') ?? 0,
      name: json['area__name']?.toString() ?? '',
    );
  }
}
