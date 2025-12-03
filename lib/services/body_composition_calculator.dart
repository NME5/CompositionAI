/// Body Composition Calculator
/// Implements the formulas from CsAlgoBuilder for calculating
/// body composition metrics from weight, impedance, and user profile data.
class BodyCompositionCalculator {
  /// Calculate Body Fat Percentage (BFR)
  /// Returns value between 5.0% and 45.0%
  static double calculateBFR({
    required double weightKg,
    required int heightCm,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    double numer;
    if (isMale) {
      numer = (-0.3315 * heightCm) + 
              (0.6216 * weightKg) + 
              (0.0183 * age) + 
              (0.0085 * impedanceOhm) + 
              22.554;
    } else {
      numer = (-0.3332 * heightCm) + 
              (0.7509 * weightKg) + 
              (0.0196 * age) + 
              (0.0072 * impedanceOhm) + 
              22.7193;
    }
    
    double bfr = (numer / weightKg) * 100.0;
    return bfr.clamp(5.0, 45.0);
  }

  /// Calculate Visceral Fat Rating (VFR)
  /// Returns value between 1.0 and 59.0, rounded to nearest integer
  static double calculateVFR({
    required int heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    if (age <= 17) return 0.0;
    
    double val;
    if (isMale) {
      val = (-0.2675 * heightCm) + 
            (0.42 * weightKg) + 
            (0.1462 * age) + 
            (0.0123 * impedanceOhm) + 
            13.9871;
    } else {
      val = (-0.1651 * heightCm) + 
            (0.2628 * weightKg) + 
            (0.0649 * age) + 
            (0.0024 * impedanceOhm) + 
            12.3445;
    }
    
    // Round to nearest integer and clamp
    return val.round().toDouble().clamp(1.0, 59.0);
  }

  /// Calculate Total Body Water Percentage (TFR)
  /// Returns value between 20.0% and 85.0%
  static double calculateTFR({
    required int heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    if (age <= 17) return 0.0;
    
    double numer;
    if (isMale) {
      // ((0.0939*H) + (0.3758*W) - (0.0032*Age) - (0.006925*Z) + 0.097) / W * 100
      numer = (0.0939 * heightCm) + 
              (0.3758 * weightKg) - 
              (0.0032 * age) - 
              (0.006925 * impedanceOhm) + 
              0.097;
    } else {
      // ((0.0877*H) + (0.2973*W) + (0.0128*Age) - (0.00603*Z) + 0.5175) / W * 100
      numer = (0.0877 * heightCm) + 
              (0.2973 * weightKg) + 
              (0.0128 * age) - 
              (0.00603 * impedanceOhm) + 
              0.5175;
    }
    
    double tfr = (numer / weightKg) * 100.0;
    return tfr.clamp(20.0, 85.0);
  }

  /// Calculate Skeletal Muscle Mass (SLM) in kg
  /// Returns value between 20.0 and 70.0 kg
  static double calculateSLM({
    required int heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    double val;
    if (isMale) {
      val = (0.2867 * heightCm) + 
            (0.3894 * weightKg) - 
            (0.0408 * age) - 
            (0.01235 * impedanceOhm) - 
            15.7665;
    } else {
      val = (0.3186 * heightCm) + 
            (0.1934 * weightKg) - 
            (0.0206 * age) - 
            (0.0132 * impedanceOhm) - 
            16.4556;
    }
    
    return val.clamp(20.0, 70.0);
  }

  /// Calculate Skeletal Muscle Mass Percentage
  static double calculateSLMPercent(double slmKg, double weightKg) {
    if (weightKg <= 0) return 0.0;
    return ((slmKg / weightKg) * 100.0);
  }

  /// Calculate Bone Mass (MSW) in kg
  /// Returns value between 1.0 and 4.0 kg
  static double calculateBoneMass({
    required double weightKg,
    required double bfrPercent,
    required double slmKg,
  }) {
    // MSW = weight - fat_mass - slm
    double fatMass = (bfrPercent / 100.0) * weightKg;
    double msw = weightKg - fatMass - slmKg;
    return msw.clamp(1.0, 4.0);
  }

  /// Calculate Basal Metabolic Rate (BMR)
  static double calculateBMR({
    required int heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    double val;
    if (isMale) {
      val = (7.5037 * heightCm) + 
            (13.1523 * weightKg) - 
            (4.3376 * age) - 
            (0.3486 * impedanceOhm) - 
            311.7751;
    } else {
      val = (7.5432 * heightCm) + 
            (9.9474 * weightKg) - 
            (3.4382 * age) - 
            (0.309 * impedanceOhm) - 
            288.2821;
    }
    return val;
  }

  /// Calculate Body Age
  /// Returns age between 18 and 80, limited to ±10 years from real age
  static int calculateBodyAge({
    required int heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
    required double impedanceOhm,
  }) {
    if (age <= 17) return 0;
    
    double val;
    if (isMale) {
      val = (-0.7471 * heightCm) + 
            (0.9161 * weightKg) + 
            (0.4184 * age) + 
            (0.0517 * impedanceOhm) + 
            54.2267;
    } else {
      val = (-1.1165 * heightCm) + 
            (1.5784 * weightKg) + 
            (0.4615 * age) + 
            (0.0415 * impedanceOhm) + 
            83.2548;
    }
    
    int est = val.round();
    // Limit to ±10 years from real age and 18..80
    est = est.clamp(age - 10, age + 10).clamp(18, 80);
    return est;
  }

  /// Calculate BMI (Body Mass Index)
  static double calculateBMI(int heightCm, double weightKg) {
    if (heightCm <= 0) return 0.0;
    double heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Calculate all body composition metrics at once
  static BodyCompositionResult calculateAll({
    required double weightKg,
    required double impedanceOhm,
    required int heightCm,
    required int age,
    required bool isMale,
  }) {
    final bfr = calculateBFR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    
    final fatMassKg = (bfr / 100.0) * weightKg;
    final vfr = calculateVFR(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    final tfr = calculateTFR(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    final slmKg = calculateSLM(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    final slmPercent = calculateSLMPercent(slmKg, weightKg);
    final boneMassKg = calculateBoneMass(
      weightKg: weightKg,
      bfrPercent: bfr,
      slmKg: slmKg,
    );
    final bmr = calculateBMR(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    final bodyAge = calculateBodyAge(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
      impedanceOhm: impedanceOhm,
    );
    final bmi = calculateBMI(heightCm, weightKg);

    return BodyCompositionResult(
      weightKg: weightKg,
      impedanceOhm: impedanceOhm,
      bfrPercent: bfr,
      fatMassKg: fatMassKg,
      vfr: vfr,
      tfrPercent: tfr,
      slmKg: slmKg,
      slmPercent: slmPercent,
      boneMassKg: boneMassKg,
      bmr: bmr,
      bodyAge: bodyAge,
      bmi: bmi,
    );
  }
}

/// Result class containing all calculated body composition metrics
class BodyCompositionResult {
  final double weightKg;
  final double impedanceOhm;
  final double bfrPercent;        // Body Fat Percentage
  final double fatMassKg;        // Fat Mass in kg
  final double vfr;              // Visceral Fat Rating
  final double tfrPercent;       // Total Body Water Percentage
  final double slmKg;            // Skeletal Muscle Mass in kg
  final double slmPercent;      // Skeletal Muscle Mass Percentage
  final double boneMassKg;       // Bone Mass in kg
  final double bmr;              // Basal Metabolic Rate
  final int bodyAge;             // Body Age
  final double bmi;              // Body Mass Index

  BodyCompositionResult({
    required this.weightKg,
    required this.impedanceOhm,
    required this.bfrPercent,
    required this.fatMassKg,
    required this.vfr,
    required this.tfrPercent,
    required this.slmKg,
    required this.slmPercent,
    required this.boneMassKg,
    required this.bmr,
    required this.bodyAge,
    required this.bmi,
  });

  @override
  String toString() {
    return 'BodyComposition(\n'
        '  BMI: ${bmi.toStringAsFixed(1)}\n'
        '  Fat: ${bfrPercent.toStringAsFixed(1)}% (${fatMassKg.toStringAsFixed(1)} kg)\n'
        '  Water: ${tfrPercent.toStringAsFixed(1)}%\n'
        '  VisceralFat: ${vfr.toStringAsFixed(1)}\n'
        '  SLM: ${slmKg.toStringAsFixed(1)} kg (${slmPercent.toStringAsFixed(1)}%)\n'
        '  Bone: ${boneMassKg.toStringAsFixed(1)} kg\n'
        '  BMR: ${bmr.toStringAsFixed(0)}\n'
        '  BodyAge: $bodyAge\n'
        ')';
  }
}
