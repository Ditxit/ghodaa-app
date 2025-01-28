class FareCalculatorService {
  /// Calculates the total fare based on distance traveled, breakpoints, and inflation.
  ///
  /// Parameters:
  /// - [totalKm]: The total kilometers for which to calculate the fare. Defaults to 0.
  /// - [breakpointKm]: The distance at which the fare increases. Defaults to 0.
  /// - [inflationMultiplierOnBreakpoint]: How much the fare increases at each breakpoint. Defaults to 0.
  /// - [farePerKm]: The base fare charged per kilometer. Defaults to 0.
  /// - [shouldRound]: If true, the total fare will be rounded up to the nearest whole number. Defaults to true.
  ///
  /// Returns:
  /// The total fare as a double. It can be rounded based on the [shouldRound] parameter.
  double calculateFare({
    double totalKm = 0,
    double breakpointKm = 0,
    double inflationMultiplierOnBreakpoint = 0,
    double farePerKm = 0,
    bool shouldRound = true,
  }) {
    // If no kilometers are traveled, return a fare of 0.0
    if (totalKm <= 0) return 0.0;

    // Calculate how much the fare increases due to inflation
    final inflationFare = inflationMultiplierOnBreakpoint * farePerKm;

    double totalFare = 0;  // Start with a total fare of 0
    int roundCount = 0;    // Count how many breakpoints we've crossed

    // Continue calculating until all kilometers have been accounted for
    while (totalKm > 0) {
      // Calculate how many kilometers to charge for this round
      final kmThisRound = (breakpointKm * (roundCount + 1) < totalKm)
          ? breakpointKm * (roundCount + 1)  // Full breakpoint distance
          : totalKm;  // Remaining kilometers

      // Calculate the fare for this round
      final fareThisRound = (farePerKm + roundCount * inflationFare) * kmThisRound;

      // Add this round's fare to the total fare
      totalFare += fareThisRound;

      // Subtract the kilometers just charged for
      totalKm -= kmThisRound;

      // Move to the next round (increment the count of breakpoints crossed)
      roundCount++;
    }

    // Return the total fare, rounded if shouldRound is true
    return shouldRound ? totalFare.ceil().toDouble() : totalFare;
  }

  /// Calculates the additional fare due to inflation for a given distance.
  ///
  /// Parameters:
  /// - [km]: The distance for which to calculate the inflation fare.
  /// - [inflationMultiplier]: The multiplier to apply to the base fare.
  /// - [baseFare]: The base fare per kilometer.
  ///
  /// Returns the additional fare due to inflation.
  double calculateInflationFare(double km, double inflationMultiplier, double baseFare) {
    return km * (inflationMultiplier * baseFare);
  }

  /// Calculates the number of complete breakpoints that fit into a total distance.
  ///
  /// Parameters:
  /// - [totalKm]: The total kilometers.
  /// - [breakpointKm]: The distance at which the fare increases.
  ///
  /// Returns the number of complete breakpoints.
  int calculateBreakpoints(double totalKm, double breakpointKm) {
    if (breakpointKm <= 0) return 0;  // Avoid division by zero
    return (totalKm / breakpointKm).floor().toInt();
  }

  /// Calculates the base fare for a given distance without inflation.
  ///
  /// Parameters:
  /// - [totalKm]: The total kilometers for which to calculate the base fare.
  /// - [farePerKm]: The base fare charged per kilometer.
  ///
  /// Returns the base fare as a double.
  double getBaseFare(double totalKm, double farePerKm) {
    return totalKm * farePerKm;
  }
}
