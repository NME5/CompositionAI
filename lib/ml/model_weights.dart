/// Weight resmi untuk model Bayesian Logistic Regression prediksi risiko diabetes
///
/// Kenapa file ini ada:
/// - Simpan semua parameter hasil training dalam satu tempat
/// - Biar gampang ngecek urutan fitur yang dipakai model
/// - Memudahkan update weight kalau ada model baru tanpa nyentuh logic
///
/// Formula masih sama kaya di `DiabetesModel`: risk = sigmoid(b0 + b1*x1 + ...)
///
/// Urutan fitur harus persis:
/// [0] BMI
/// [1] BodyFat%
/// [2] VisceralFat
/// [3] MuscleMass (kg)
/// [4] MetabolicAgeDifference (bodyAge - actualAge)
/// [5] WeightTrend14Days (kg change over 14 days)
/// [6] ActivityScore (0.0-1.0 normalized)
///
/// Update weight? tinggal ganti value di bawah sesuai hasil retraining.
class DiabetesModelWeights {
  /// Nilai intercept (b0) - baseline odds saat semua fitur = 0
  static const double intercept = -2.847;

  /// Deretan weight fitur (b1, b2, ..., b7)
  ///
  /// Semua angka ini hasil training offline. Kalau retrain model → update di sini.
  static const List<double> featureWeights = [
    0.082,   // BMI
    0.045,   // BodyFat%
    0.127,   // VisceralFat
    -0.031,  // MuscleMass (negative = higher muscle = lower risk)
    0.089,   // MetabolicAgeDifference
    0.156,   // WeightTrend14Days (positive trend = higher risk)
    -0.203,  // ActivityScore (negative = higher activity = lower risk)
  ];

  /// Nama human-readable buat tiap fitur, biar gampang ditampilkan di UI/debugging
  static const List<String> featureNames = [
    'BMI',
    'Body Fat %',
    'Visceral Fat',
    'Muscle Mass',
    'Metabolic Age Difference',
    'Weight Trend (14 days)',
    'Activity Score',
  ];

  /// Total fitur yang dipakai model (harus sama panjang dengan weight)
  static int get featureCount => featureWeights.length;

  /// Quick check: pastikan jumlah weight = jumlah nama fitur
  static bool get isValid => featureWeights.length == featureNames.length;
}

