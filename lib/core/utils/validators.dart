import 'package:flutter/material.dart';

/// Validators réutilisables pour les formulaires.
class Validators {
  /// Valide qu'une valeur n'est pas vide.
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }

  /// Valide un email avec vérification du format et du domaine @pbservices.africa.
  static String? email(String? value, {bool requirePbsDomain = true}) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre email';
    }

    final email = value.trim().toLowerCase();

    if (!email.contains('@')) {
      return 'Veuillez entrer un email valide';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer un email valide';
    }

    if (requirePbsDomain && !email.endsWith('@pbservices.africa')) {
      return 'Veuillez utiliser votre email professionnel de PBS (@pbservices.africa)';
    }

    return null;
  }

  /// Valide un mot de passe avec règles de sécurité.
  ///
  /// Le mot de passe doit contenir :
  /// - Au moins 8 caractères
  /// - Au moins une majuscule
  /// - Au moins une minuscule
  /// - Au moins un chiffre
  /// - Au moins un caractère spécial
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    // Vérifier qu'il y a au moins une majuscule
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    // Vérifier qu'il y a au moins une minuscule
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    // Vérifier qu'il y a au moins un chiffre
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    // Vérifier qu'il y a au moins un caractère spécial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial (!@#\$%^&*(),.?":{}|<>)';
    }

    return null;
  }

  /// Valide que la confirmation du mot de passe correspond au mot de passe.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valide un nom avec longueur minimale.
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre nom complet';
    }
    if (value.trim().length < minLength) {
      return 'Le nom doit contenir au moins $minLength caractères';
    }
    return null;
  }

  /// Valide un code OTP à 6 chiffres.
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Ne pas valider si vide (validation globale)
    }

    if (!RegExp(r'^\d$').hasMatch(value)) {
      return '';
    }

    return null;
  }

  /// Valide que tous les champs OTP sont remplis.
  static bool validateOtpFields(List<TextEditingController> controllers) {
    return controllers.every((controller) =>
        controller.text.isNotEmpty &&
        RegExp(r'^\d$').hasMatch(controller.text));
  }

  /// Valide un code OTP complet (6 chiffres).
  static String? otpComplete(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le code de vérification';
    }

    final cleaned =
        value.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return 'Le code doit contenir exactement 6 chiffres';
    }

    return null;
  }
}
