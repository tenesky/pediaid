import 'dart:math' as math;

class PediFormulas {
  // Weight estimation
  static double estWeightKgByMonths(int months) {
    if (months <= 0) return 3.5; // newborn approx
    if (months <= 12) {
      return (months / 2.0) + 4.0;
    }
    // If >12 months but using months API, convert to years formula fallback
    final years = months / 12.0;
    return estWeightKgByYears(years);
  }

  static double estWeightKgByYears(double years) {
    if (years < 1.0) {
      // if under 1 year, approximate newborn 3.5 kg
      return 3.5;
    }
    if (years <= 10.0) {
      return (years * 2.0) + 8.0;
    }
    // beyond 10 years, keep linear suggestion (still MVP placeholder)
    return (years * 3.0) + 7.0;
  }

  // Height approximation
  static double estHeightCmByMonths(int months) {
    if (months <= 12) {
      return 50.0 + (months * 2.0);
    }
    final years = months / 12.0;
    return estHeightCmByYears(years);
  }

  static double estHeightCmByYears(double years) {
    if (years <= 12) {
      return (years * 6.0) + 77.0;
    }
    return (12 * 6.0) + 77.0 + ((years - 12) * 5.0);
  }

  // Body surface area (Mosteller)
  static double bsaMosteller(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    return math.sqrt((heightCm * weightKg) / 3600.0);
  }

  // Fluids
  static double fluidsDailyHollidaySegar(double weightKg) {
    // 100/50/20 rule (ml/day)
    if (weightKg <= 0) return 0.0;
    double remaining = weightKg;
    double total = 0.0;
    final first10 = math.min(10.0, remaining);
    total += first10 * 100.0;
    remaining -= first10;
    if (remaining > 0) {
      final next10 = math.min(10.0, remaining);
      total += next10 * 50.0;
      remaining -= next10;
    }
    if (remaining > 0) {
      total += remaining * 20.0;
    }
    return total; // ml/day
  }

  static double fluidsHourly421(double weightKg) {
    // 4-2-1 rule (ml/hour)
    if (weightKg <= 0) return 0.0;
    double remaining = weightKg;
    double rate = 0.0;
    final first10 = math.min(10.0, remaining);
    rate += first10 * 4.0;
    remaining -= first10;
    if (remaining > 0) {
      final next10 = math.min(10.0, remaining);
      rate += next10 * 2.0;
      remaining -= next10;
    }
    if (remaining > 0) {
      rate += remaining * 1.0;
    }
    return rate; // ml/hour
  }

  // Defibrillation energy (J): 4 J/kg
  static double defibrillationEnergyJ(double weightKg) => weightKg * 4.0;

  // Blood volume ~80 ml/kg
  static double bloodVolumeMl(double weightKg) => weightKg * 80.0;

  // Shock index = HR / systolic BP
  static double shockIndex({required double heartRate, required double systolicBP}) {
    if (systolicBP <= 0) return 0.0;
    return heartRate / systolicBP;
  }

  // Oxygen consumption rough: children ~6 ml/kg/min, neonates ~8 ml/kg/min
  static double oxygenConsumptionMlPerMin({required double weightKg, bool neonate = false}) {
    return weightKg * (neonate ? 8.0 : 6.0);
  }

  // Equipment helpers (examples)
  static double tubeSizeNoCuff(double years) => (years / 4.0) + 4.0;
  static double tubeSizeCuff(double years) => (years / 4.0) + 3.5;
  static double tubeDepthCm(double years) => (years / 2.0) + 12.0;
  static String laryngealTubeSizeByWeight(double weightKg) {
    if (weightKg < 10.0) return '2';
    if (weightKg <= 20.0) return '2.5';
    return '3';
  }
}
