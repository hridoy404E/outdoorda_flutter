/// Pet model representing a user's pet information
/// Used in customer settings for managing pets
class Pet {
  final String id;
  final String name;
  final String type;
  final String size;
  final String? breed;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.breed,
  });

  /// Create Pet from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      breed: json['breed']?.toString(),
    );
  }

  /// Convert Pet to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      if (breed != null) 'breed': breed,
    };
  }

  /// Create copy of Pet with updated fields
  Pet copyWith({
    String? id,
    String? name,
    String? type,
    String? size,
    String? breed,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      breed: breed ?? this.breed,
    );
  }

  @override
  String toString() {
    return 'Pet{id: $id, name: $name, type: $type, size: $size, breed: $breed}';
  }
}
