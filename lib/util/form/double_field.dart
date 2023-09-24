import 'package:flutter/material.dart';

class DoubleInputField extends TextFormField {
  final String? labelText;
  final String? hintText;
  final double? initValue;
  final double? minValue;
  final double? maxValue;

  /// Whether the value is nullable: not required.
  ///
  /// If false, checks if the value is not null before [onValueChange] and
  /// [valueValidator] called, and never pass null.
  final bool nullable;

  /// Whether allows [double.infinity] as a input.
  ///
  /// If false, checks if the value is not null before [onValueChange] and
  /// [valueValidator] called, and never pass [double.infinity].
  final bool allowInf;

  /// Whether allows [double.negativeInfinity] as a input.
  ///
  /// If false, checks if the value is not null before [onValueChange] and
  /// [valueValidator] called, and never pass [double.negativeInfinity].
  final bool allowNegativeInf;

  /// Whether allows [double.nan] as a input.
  ///
  /// If false, checks if the value is not null before [onValueChange] and
  /// [valueValidator] called, and never pass [double.nan].
  final bool allowNaN;

  final void Function(double?)? onValueChange;
  final String? Function(double?)? valueValidator;

  DoubleInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.initValue,
    this.minValue,
    this.maxValue,
    this.nullable = true,
    this.allowInf = false,
    this.allowNegativeInf = false,
    this.allowNaN = false,
    this.onValueChange,
    this.valueValidator,
  }) : super(
          initialValue: initValue?.toString(),
          decoration: InputDecoration(
              labelText: labelText != null || !nullable
                  ? [labelText ?? "", nullable ? "" : "*"].join(" ")
                  : null,
              hintText: hintText),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final doubleValue = double.tryParse(value);

            if (!nullable && doubleValue == null) {
              return;
            }

            if (doubleValue != null) {
              if ((!allowInf && doubleValue == double.infinity) ||
                  (!allowNegativeInf &&
                      doubleValue == double.negativeInfinity) ||
                  (!allowNaN && doubleValue.isNaN)) {
                return;
              }

              if ((minValue != null && doubleValue < minValue) ||
                  (maxValue != null && doubleValue > maxValue)) {
                return;
              }
            }

            onValueChange?.call(doubleValue);
          },
          validator: (value) {
            final doubleValue = value != null ? double.tryParse(value) : null;

            if (!nullable && doubleValue == null) {
              if (value?.isEmpty ?? true) {
                return "This field is required.";
              }
              return "Must be a real number.";
            }

            if (doubleValue != null) {
              if (!allowInf && doubleValue == double.infinity) {
                return "Infinity is not allowed.";
              }
              if (!allowNegativeInf && doubleValue == double.negativeInfinity) {
                return "Negative infinity is not allowed.";
              }
              if (!allowNaN && doubleValue.isNaN) {
                return "Not a Number is not allowed.";
              }

              if (minValue != null && doubleValue < minValue) {
                return "Must be >= $minValue.";
              }
              if (maxValue != null && doubleValue > maxValue) {
                return "Must be <= $maxValue.";
              }
            }

            return valueValidator?.call(doubleValue);
          },
        );
}
