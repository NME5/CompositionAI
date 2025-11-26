# Health Measurement Thresholds and Logic

dokumen adalah menjadi petunjuk untuk mengukur metrics (weight, BMI, fat, muscle, etc.) dalam range sehat atau tidak.

## Overview

The app uses a **level-based system** (typically 1-4 levels) to determine health status:
- **Level 1**: Low/Thin/Unhealthy (dibawah standard)
- **Level 2**: Standard/Healthy (dalam healthy range) 
- **Level 3**: Slightly High/Fat (diatas standard but not too high)
- **Level 4**: High/Corpulent/Dangerous (sangat tinggi)

## 1. BMI (Body Mass Index)

### Standard Ranges (varies by region):
- **Mainland China**: `[14.0, 18.5, 23.9, 26.9, 40.0]`
- **Southeast Asia**: `[14.0, 18.5, 22.9, 27.5, 40.0]`
- **Other regions**: `[14.0, 18.5, 24.9, 29.9, 40.0]`
- **HowbodyPomelo**: `[4.0, 18.5, 24.0, 28.0, 55.5]`

### Health Levels (`getBmiLevel`):
- **Level 1**: BMI < 18.5 (Underweight)
- **Level 2**: 18.5 ≤ BMI < 23.9 (Normal/Healthy)
- **Level 3**: 23.9 ≤ BMI < 28.0 (Overweight)
- **Level 4**: BMI ≥ 28.0 (Obese)

**Method**: `StandardUtil.getBmiLevel(WeightEntity weightEntity)`

---

## 2. Body Fat Percentage (Axunge)

### Standard Ranges by Gender and Age:

#### Male (男):
- **Age ≤ 39**: `[5.0, 11.0, 17.0, 27.0, 45.0]`
- **Age 40-59**: `[5.0, 12.0, 18.0, 28.0, 45.0]`
- **Age ≥ 60**: `[5.0, 14.0, 20.0, 30.0, 45.0]`

#### Female (女):
- **Age ≤ 39**: `[5.0, 21.0, 28.0, 40.0, 45.0]`
- **Age 40-59**: `[5.0, 22.0, 29.0, 41.0, 45.0]`
- **Age ≥ 60**: `[5.0, 23.0, 30.0, 42.0, 45.0]`

### Health Levels (`getAxungeLevel`):

#### Male:
- **Age ≤ 39**:
  - Level 1: < 11.0%
  - Level 2: 11.0% - 17.0%
  - Level 3: 17.0% - 27.0%
  - Level 4: ≥ 27.0%

- **Age 40-59**:
  - Level 1: < 12.0%
  - Level 2: 12.0% - 18.0%
  - Level 3: 18.0% - 28.0%
  - Level 4: ≥ 28.0%

- **Age ≥ 60**:
  - Level 1: < 14.0%
  - Level 2: 14.0% - 20.0%
  - Level 3: 20.0% - 30.0%
  - Level 4: ≥ 30.0%

#### Female:
- **Age ≤ 39**:
  - Level 1: < 21.0%
  - Level 2: 21.0% - 28.0%
  - Level 3: 28.0% - 40.0%
  - Level 4: ≥ 40.0%

- **Age 40-59**:
  - Level 1: < 22.0%
  - Level 2: 22.0% - 29.0%
  - Level 3: 29.0% - 41.0%
  - Level 4: ≥ 41.0%

- **Age ≥ 60**:
  - Level 1: < 23.0%
  - Level 2: 23.0% - 30.0%
  - Level 3: 30.0% - 42.0%
  - Level 4: ≥ 42.0%

**Method**: `StandardUtil.getAxungeLevel(RoleInfo roleInfo, WeightEntity weightEntity)`

---

## 3. Muscle Mass

### Skeletal Muscle Percentage (GuMuscle):

#### Male (by height):
- **Height < 160cm**: `[6.0, 21.2, 26.6, 82.0]`
- **Height 160-170cm**: `[6.0, 24.8, 34.6, 82.0]`
- **Height > 170cm**: `[6.0, 29.6, 43.2, 82.0]`

#### Female (by height):
- **Height < 150cm**: `[6.0, 16.0, 20.6, 82.0]`
- **Height 150-160cm**: `[6.0, 18.9, 23.7, 82.0]`
- **Height > 160cm**: `[6.0, 22.1, 30.3, 82.0]`

### Total Muscle Percentage:

#### Male (by height):
- **Height < 160cm**: `[7.0, 38.5, 46.5, 141.5]`
- **Height 160-170cm**: `[7.0, 44.0, 52.4, 141.5]`
- **Height > 170cm**: `[7.0, 49.4, 59.4, 141.5]`

#### Female (by height):
- **Height < 150cm**: `[7.0, 29.1, 34.7, 141.5]`
- **Height 150-160cm**: `[7.0, 32.9, 37.5, 141.5]`
- **Height > 160cm**: `[7.0, 36.5, 42.5, 141.5]`

### Health Levels (`getMuscleLevel`):
- **Level 1**: Below standard range (Low)
- **Level 2**: Within standard range (Standard/Healthy)
- **Level 3**: Above standard range (High)

**Method**: `StandardUtil.getMuscleLevel(Context context, RoleInfo roleInfo, WeightEntity weightEntity)`

---

## 4. Body Water Percentage

### Standard Ranges by Gender and Age:

#### Male:
- **Age ≤ 30**: `[37.8, 53.6, 57.0, 66.0]`
- **Age > 30**: `[37.8, 52.3, 55.6, 66.0]`

#### Female:
- **Age ≤ 30**: `[37.8, 49.5, 52.9, 66.0]`
- **Age > 30**: `[37.8, 48.1, 51.5, 66.0]`

### Health Levels (`getWaterLevel`):

#### Male:
- **Age ≤ 30**:
  - Level 1: < 53.6%
  - Level 2: 53.6% - 57.0%
  - Level 3: > 57.0%

- **Age > 30**:
  - Level 1: ≤ 52.3%
  - Level 2: 52.3% - 55.6%
  - Level 3: > 55.6%

#### Female:
- **Age ≤ 30**:
  - Level 1: < 49.5%
  - Level 2: 49.5% - 52.9%
  - Level 3: > 52.9%

- **Age > 30**:
  - Level 1: < 48.1%
  - Level 2: 48.1% - 51.5%
  - Level 3: > 51.5%

**Method**: `StandardUtil.getWaterLevel(RoleInfo roleInfo, WeightEntity weightEntity)`

---

## 5. Visceral Fat

### Standard Range:
`[1.0, 5.0, 10.0, 15.0, 59.0]`

### Health Levels (`getVisceraLevel`):
- **Level 1**: < 1.0 (Very Low)
- **Level 2**: 1.0 - 9.0 (Standard/Healthy)
- **Level 3**: 10.0 - 14.0 (High)
- **Level 4**: > 14.0 (Dangerous)

**Method**: `StandardUtil.getVisceraLevel(WeightEntity weightEntity)`

---

## 6. Bone Mass

### Standard Ranges by Gender and Age:

#### Male:
- **Age ≤ 54**: `[0.7 * 2.4, 2.4, 1.3 * 2.4, 5.0]` = `[1.68, 2.4, 3.12, 5.0]`
- **Age 55-75**: `[0.7 * 2.8, 2.8, 1.3 * 2.8, 5.0]` = `[1.96, 2.8, 3.64, 5.0]`
- **Age > 75**: `[0.7 * 3.1, 3.1, 1.3 * 3.1, 5.0]` = `[2.17, 3.1, 4.03, 5.0]`

#### Female:
- **Age ≤ 39**: `[0.7 * 1.7, 1.7, 1.3 * 1.7, 5.0]` = `[1.19, 1.7, 2.21, 5.0]`
- **Age 40-60**: `[0.7 * 2.1, 2.1, 1.3 * 2.1, 5.0]` = `[1.47, 2.1, 2.73, 5.0]`
- **Age > 60**: `[0.7 * 2.4, 2.4, 1.3 * 2.4, 5.0]` = `[1.68, 2.4, 3.12, 5.0]`

### Health Levels (`getBoneLevel`):
Level is calculated based on how many standard thresholds the bone mass exceeds.

**Method**: `StandardUtil.getBoneLevel(RoleInfo roleInfo, WeightEntity weightEntity)`

---

## 7. Basal Metabolic Rate (BMR/Metabolism)

### Standard Ranges by Gender and Age:

#### Male:
- **Age ≤ 2**: `[665, 700, 735]` (95%-105% of 700)
- **Age 3-5**: `[855, 900, 945]` (95%-105% of 900)
- **Age 6-8**: `[1035.5, 1090, 1144.5]` (95%-105% of 1090)
- **Age 9-11**: `[1225.5, 1290, 1354.5]` (95%-105% of 1290)
- **Age 12-14**: `[1406, 1480, 1554]` (95%-105% of 1480)
- **Age 15-17**: `[1529.5, 1610, 1690.5]` (95%-105% of 1610)
- **Age 18-29**: `[1472.5, 1550, 1627.5]` (95%-105% of 1550)
- **Age 30-49**: `[1425, 1500, 1575]` (95%-105% of 1500)
- **Age 50-69**: `[1282.5, 1350, 1417.5]` (95%-105% of 1350)
- **Age ≥ 70**: `[1159, 1220, 1281]` (95%-105% of 1220)

#### Female:
- **Age ≤ 2**: `[665, 700, 735]` (95%-105% of 700)
- **Age 3-5**: `[817, 860, 903]` (95%-105% of 860)
- **Age 6-8**: `[950, 1000, 1050]` (95%-105% of 1000)
- **Age 9-11**: `[1121, 1180, 1239]` (95%-105% of 1180)
- **Age 12-14**: `[1273, 1340, 1407]` (95%-105% of 1340)
- **Age 15-17**: `[1235, 1300, 1365]` (95%-105% of 1300)
- **Age 18-29**: `[1149.5, 1210, 1270.5]` (95%-105% of 1210)
- **Age 30-49**: `[1111.5, 1170, 1228.5]` (95%-105% of 1170)
- **Age 50-69**: `[1054.5, 1110, 1165.5]` (95%-105% of 1110)
- **Age ≥ 70**: `[959.5, 1010, 1060.5]` (95%-105% of 1010)

### Health Levels (`getMetabolismLevel`):
- **Level 1**: BMR ≤ 95% of standard (Low)
- **Level 2**: 95% < BMR ≤ 105% of standard (Standard/Healthy)
- **Level 3**: BMR > 105% of standard (High)

**Method**: `StandardUtil.getMetabolismLevel(RoleInfo roleInfo, WeightEntity weightEntity)`

---

## 8. Protein Percentage

### Standard Range:
`[16.0, 20.0]`

### Health Levels (`getProteinLevel`):
- **Level 1**: < 16.0% (Low)
- **Level 2**: 16.0% - 20.0% (Standard/Healthy)
- **Level 3**: > 20.0% (High)

**Method**: `StandardUtil.getProteinLevel(float protein)`

---

## 9. Weight (based on BMI)

Weight standards are calculated from BMI ranges based on height:
- Healthy weight range: BMI 18.5 to 23.9 (or region-specific)

**Method**: `StandardUtil.getWeightStandard(float height)` returns `[minWeight, maxWeight]`

---

## 10. Obesity Degree (Corpulent)

### Calculation:
```
OD = ((Weight - BW) / BW) * 100
where BW (Body Weight) = (Height - 80) * 0.7 for male, or (Height - 70) * 0.6 for female
```

### Health Levels (`getCorpulentLevel`):
- **Level 1**: -10% ≤ OD ≤ 10% (Standard)
- **Level 2**: 10% < OD ≤ 20% (Slightly Fat)
- **Level 3**: 20% < OD ≤ 30% (Fat)
- **Level 4**: 30% < OD ≤ 50% (Very Fat)
- **Level 5**: OD > 50% (Extremely Fat)

**Method**: `StandardUtil.getCorpulentLevel(float obesityDegree)`

---

## Health Status Determination

The main method for determining health status is:

```java
public ArrayList<Integer> getHealthStatus(float min, float max, float value, ArrayList<Integer> statusList)
```

This returns:
- **Standard**: if `min ≤ value ≤ max`
- **Slight Thin**: if `value < min`
- **Slight Fat**: if `value > max`

---

## Notes

1. **Age Calculation**: Age is calculated from birthday to measurement time
2. **Gender**: Uses "男" (Male) or "女" (Female) strings
3. **Height**: Used in cm
4. **Weight**: Used in kg (converted from other units if needed)
5. **Regional Differences**: BMI standards vary by region (China, Southeast Asia, Others)
6. **Level Calculation**: The `calLevel` method in `BodyMeasureReportItemUtils` counts how many threshold values the measurement exceeds

---

## Implementation Example

To check if a measurement is healthy:

```java
// For BMI
int bmiLevel = StandardUtil.getBmiLevel(weightEntity);
boolean isHealthy = (bmiLevel == 2); // Level 2 is healthy

// For Body Fat
int fatLevel = StandardUtil.getAxungeLevel(roleInfo, weightEntity);
boolean isHealthy = (fatLevel == 2); // Level 2 is healthy

// For Water
int waterLevel = StandardUtil.getWaterLevel(roleInfo, weightEntity);
boolean isHealthy = (waterLevel == 2); // Level 2 is healthy
```


