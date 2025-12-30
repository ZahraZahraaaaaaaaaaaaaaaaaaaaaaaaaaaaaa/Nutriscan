enum Gender { male, female, other }

enum HealthGoal {
  maintainWeight,
  loseWeight,
  gainWeight,
  eatHealthier,
}

enum Disease {
  diabetes,
  heartDisease,
  highCholesterol,
  obesity,
  pcos,
  none,
}

class UserProfile {
  final int? age;
  final Gender? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final List<Disease> diseases;
  final HealthGoal? goal;
  final bool isComplete;

  UserProfile({
    this.age,
    this.gender,
    this.height,
    this.weight,
    List<Disease>? diseases,
    this.goal,
  })  : diseases = diseases ?? [],
        isComplete = age != null &&
            gender != null &&
            height != null &&
            weight != null &&
            (diseases == null ||
                diseases.isEmpty ||
                !diseases.contains(Disease.none));

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int?,
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString() == 'Gender.${json['gender']}',
              orElse: () => Gender.other,
            )
          : null,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      diseases: json['diseases'] != null
          ? (json['diseases'] as List)
              .map((e) => Disease.values.firstWhere(
                    (d) => d.toString() == 'Disease.$e',
                    orElse: () => Disease.none,
                  ))
              .where((d) => d != Disease.none)
              .toList()
          : [],
      goal: json['goal'] != null
          ? HealthGoal.values.firstWhere(
              (e) => e.toString() == 'HealthGoal.${json['goal']}',
              orElse: () => HealthGoal.eatHealthier,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender?.toString().split('.').last,
      'height': height,
      'weight': weight,
      'diseases': diseases.map((d) => d.toString().split('.').last).toList(),
      'goal': goal?.toString().split('.').last,
    };
  }

  UserProfile copyWith({
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    List<Disease>? diseases,
    HealthGoal? goal,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      diseases: diseases ?? this.diseases,
      goal: goal ?? this.goal,
    );
  }

  bool get hasDiabetes => diseases.contains(Disease.diabetes);
  bool get hasHeartDisease => diseases.contains(Disease.heartDisease);
  bool get hasHighCholesterol => diseases.contains(Disease.highCholesterol);
  bool get hasObesity => diseases.contains(Disease.obesity);
  bool get hasPCOS => diseases.contains(Disease.pcos);
}
