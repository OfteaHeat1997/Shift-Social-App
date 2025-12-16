import 'package:flutter/material.dart';
import 'package:shift_application/models/statement.dart';

/// Service class for handling bracelet-related functionality
class BraceletService {
  /// Converts a hex color string to a Color object
  /// Example: "#FF5500" becomes a Color object
  static Color fromHex(String hex) {
    // Remove the # prefix if present
    final cleaned = hex.replaceFirst('#', '');
    // Parse the hex string to an integer and add the alpha channel (FF)
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  /// Gets the appropriate bracelet color based on the stance and statement
  /// 
  /// Parameters:
  /// - stance: The user's stance (Agree/Disagree/Neutral)
  /// - statement: The statement object containing color information
  /// 
  /// Returns:
  /// - Color: The appropriate color for the bracelet
  static Color getBraceletColor(String stance, Statement statement) {
    if (stance == 'Agree') {
      return fromHex(statement.agreeColor);
    } else if (stance == 'Disagree') {
      return fromHex(statement.disagreeColor);
    } else {
      return fromHex(statement.neutralColor);
    }
  }
}