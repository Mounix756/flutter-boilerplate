import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget réutilisable pour la saisie de code OTP à 6 chiffres.
///
/// Gère automatiquement la navigation entre les champs et la validation.
///
/// Exemple d'utilisation:
/// ```dart
/// final otpKey = GlobalKey<OtpInputFieldState>();
/// OtpInputField(
///   key: otpKey,
///   onCompleted: (code) => print('Code: $code'),
/// )
/// final code = otpKey.currentState?.getOtpCode();
/// ```
class OtpInputField extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool autoFocus;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.validator,
    this.autoFocus = false,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _focusNodes.add(FocusNode());
      _controllers.add(TextEditingController());
    }
    if (widget.autoFocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _getOtpCode();
    widget.onChanged?.call(otp);
    if (otp.length == widget.length) {
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    final otp = _getOtpCode();
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  String _getOtpCode() {
    return _controllers
        .map((c) => c.text.trim().replaceAll(RegExp(r'\s+'), ''))
        .where((text) => text.isNotEmpty)
        .join();
  }

  /// Réinitialise tous les champs OTP.
  void reset() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  /// Retourne le code OTP complet.
  String getOtpCode() {
    return _getOtpCode();
  }

  /// Vérifie si tous les champs sont remplis.
  bool isComplete() {
    return _getOtpCode().length == widget.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 50,
          height: 60,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onCodeChanged(value, index),
            validator: widget.validator != null
                ? (value) => widget.validator!(value)
                : null,
          ),
        ),
      ),
    );
  }
}
