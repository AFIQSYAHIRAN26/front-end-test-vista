class Company {
  final int id;
  final String name;
  final String registrationNumber;

  Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name' : name,
      'registrationNumber' : registrationNumber,
    };
  }
}