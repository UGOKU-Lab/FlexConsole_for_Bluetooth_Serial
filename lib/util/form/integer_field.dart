import 'package:flutter/material.dart';

class IntInputField extends TextFormField {
  final String? labelText;
  final String? hintText;
  final int? initValue;
  final int? minValue;
  final int? maxValue;

  /// Whether the value is nullable: not required.
  ///
  /// If false, checks if the value is not null before [onValueChange] and
  /// [valueValidator] are called, and never pass null.
  final bool nullable;

  final void Function(int?)? onValueChange;
  final String? Function(int?)? valueValidator;

  IntInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.initValue,
    this.minValue,
    this.maxValue,
    this.nullable = true,
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
            final intValue = int.tryParse(value);

            if (!nullable && intValue == null) {
              return;
            }

            if (intValue != null) {
              if ((minValue != null && intValue < minValue) ||
                  (maxValue != null && intValue > maxValue)) {
                return;
              }
            }

            onValueChange?.call(intValue);
          },
          validator: (value) {
            final intValue = value != null ? int.tryParse(value) : null;

            if (!nullable && intValue == null) {
              if (value?.isEmpty ?? true) {
                return "This field is required.";
              }
              return "Must be an integer number.";
            }

            if (intValue != null) {
              if (minValue != null && intValue < minValue) {
                return "Must be >= $minValue.";
              }
              if (maxValue != null && intValue > maxValue) {
                return "Must be <= $maxValue.";
              }
            }

            return valueValidator?.call(intValue);
          },
        );
}
