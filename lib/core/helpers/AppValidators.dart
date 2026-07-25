extension AppValidators on String? {
  /// Validates an email address.
  ///
  /// Returns an error message if the email is empty, lacks '@' symbol,
  /// or has incorrect format (e.g., multiple '@' symbols).
  String? email() {
    if (this == null || this!.isEmpty) {
      return 'Email is required';
    }
    if (!this!.contains('@')) {
      return 'Invalid email address';
    }
    final split = this!.split('@');
    if (split.length != 2 || split.contains('')) {
      return 'Invalid email address';
    }

    return null;
  }

  /// Validates a password.
  ///
  /// Returns an error message if the password is empty, shorter than 8 characters,
  /// or lacks at least one number, one uppercase letter, and one special character.
  String? password() {
    if (this == null || this!.isEmpty) {
      return 'Password is required';
    }
    if (this!.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!this!.contains(RegExp('[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!this!.contains(RegExp('[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    // if (!password
    //     .contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"|,.<>\/?' "'" ']'))) {
    //   return 'Password must contain a special character %#@\$';
    // }

    return null;
  }

  /// Validates if a value is required.
  ///
  /// Returns an error message if the value is null or empty.
  String? required() {
    if (this == null || this!.isEmpty) {
      return 'Required';
    }
    return null;
  }

  /// Validates if a value's length is exact.
  ///
  /// Returns an error message if the value is null, empty, or its length
  /// does not match the specified [length].
  String? numbersExactLength(int length) {
    if (this == null || this!.isEmpty) {
      return 'Required';
    }
    if (this!.length != length) {
      return 'This field must be $length characters long';
    }
    return null;
  }

  /// Validates if a value's length is at least [length].
  ///
  /// Returns an error message if the value is null, empty, or its length
  /// is less than [length].
  String? minLength(int length) {
    if (this == null || this!.isEmpty) {
      return 'Required';
    }
    if (this!.length < length) {
      return 'This field must be at least $length characters long';
    }
    return null;
  }

  /// Validates a phone number.
  ///
  /// Returns an error message if the value is null, empty, or contains non-numeric characters.
  String? phoneNumber() {
    if (this == null || this!.isEmpty) {
      return 'Required';
    }
    if (!this!.contains(RegExp('^[0-9]*\$'))) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Validates if a value is identical to another.
  ///
  /// Returns an error message if the value is null, empty, or not identical to [other].
  String? identical(String? other) {
    if (this == null || this!.isEmpty) {
      return 'Required';
    }
    if (this! != other) {
      return 'Does not match';
    }
    return null;
  }
}
