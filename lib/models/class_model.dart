class ClassModel {
  final String id;
  final String year;
  final String branch;
  final String section;

  ClassModel({
    required this.id,
    required this.year,
    required this.branch,
    required this.section,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'branch': branch,
      'section': section,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      year: map['year'] ?? '',
      branch: map['branch'] ?? '',
      section: map['section'] ?? '',
    );
  }
}
