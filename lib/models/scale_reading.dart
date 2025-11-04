class ScaleReading {
  final double? weightKg;
  final double impedanceOhm;
  final int unitStatus;
  final String rawHex;
  final int mfgId;
  final int? rssi;

  ScaleReading({
    this.weightKg,
    required this.impedanceOhm,
    required this.unitStatus,
    required this.rawHex,
    required this.mfgId,
    this.rssi,
  });

  bool get hasValidWeight => weightKg != null && weightKg! > 0;
  bool get hasValidImpedance => impedanceOhm > 0;

  @override
  String toString() {
    return 'ScaleReading(weight: $weightKg kg, impedance: $impedanceOhm Ω, status: 0x${unitStatus.toRadixString(16)}, mfg: 0x${mfgId.toRadixString(16)}, rssi: $rssi dBm)';
  }
}
