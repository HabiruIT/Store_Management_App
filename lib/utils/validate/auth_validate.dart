import 'package:flutter/material.dart';

class AuthValidate {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Vui lòng nhập email";
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  static String? validatePasswordLogin(String? password) {
    if (password == null || password.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }

    if (password.length < 8) {
      return "Mật khẩu phải có ít nhất 8 ký tự";
    }

    if (!RegExp(r'^[a-zA-Z0-9!@#\$%^&*(),.?":{}|<>]+$').hasMatch(password)) {
      return 'Mật khẩu chứa ký tự không hợp lệ';
    }

    return null;
  }

  static FormFieldValidator<String>? validatePasswordRegister(
    String? password,
    String? confirmPassword,
  ) {
    return (value) {
      if (password == null || password.isEmpty) {
        return "Vui lòng nhập mật khẩu";
      }

      if (password != confirmPassword) {
        return "Xác nhận mật khẩu không đúng";
      }

      if (password.length < 8) {
        return "Mật khẩu phải có ít nhất 8 ký tự";
      }

      if (!RegExp(r'[0-9]').hasMatch(password) ||
          !RegExp(r'[A-Z]').hasMatch(password) ||
          !RegExp(r'[a-z]').hasMatch(password) ||
          !RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
        return 'Mật khẩu phải chứa số, chữ hoa, chữ thường và ký tự đặc biệt';
      }

      if (!RegExp(r'^[a-zA-Z0-9!@#\$%^&*(),.?":{}|<>]+$').hasMatch(password)) {
        return 'Mật khẩu chứa ký tự không hợp lệ';
      }

      return null;
    };
  }
}
