class Validate {
  ///Password Validation
  static String? password(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Please provide a password";
    } else if (val.length < 6) {
      return 'Password must be at least 6 characters';
    } else if (!_containsUpperCase(val)) {
      return 'Password must contain one uppercase letter';
    } else if (!_containsNumber(val)) {
      return 'Password must contain one number';
    } else if (!_containsSpecialCharacter(val)) {
      return 'Password must contain one special character';
    }
    return null;
  }

  static String? loginPassword(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Please provide a password";
    } else if (val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static bool _containsUpperCase(String val) {
    return val.contains(RegExp(r'[A-Z]'));
  }

  static bool _containsNumber(String val) {
    return val.contains(RegExp(r'[0-9]'));
  }

  static bool _containsSpecialCharacter(String val) {
    return val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  ///Confirm Password Validation
  static String? confirmPassword(val, String? pass) {
    if (val!.trim().isEmpty) {
      return "Please provide Password";
    } else if (val.length != pass?.length) {
      return 'Password length does not match';
    } else if (val != pass) {
      return 'Password does not match';
    }
    return null;
  }

  ///Email Validation
  static String? email(val) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(val);
    if (val.isEmpty) {
      return "Please provide email";
    } else if (!emailValid) {
      return 'Invalid Email (i.e): abcd123@domain.com';
    }
    if (val.isEmpty) {
      return "Please provide Email";
    }
    return null;
  }

  ///Name validation
  static String? name(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Please add a valid input';
    }
    // Allow alphanumeric characters, spaces, and basic punctuation
    var nameRegex = RegExp(r"^[a-zA-Z0-9\s.,!&'-]+$").hasMatch(val);
    if (!nameRegex) {
      return 'Please use letters, numbers, and basic punctuation only';
    }
    return null;
  }

  static String? number(String? val) {
    // bool isValidName =
    //     RegExp(r"^[a-zA-Z][a-zA-Z\s]{0,20}[a-zA-Z]$").hasMatch(val!);
    var nameRegex = RegExp(r"^[0-9]+$").hasMatch(val!);
    if (val.isEmpty || !nameRegex) {
      return 'valid Number ?';
    }
    return null;
  }
}
