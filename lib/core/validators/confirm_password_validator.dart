String? confirmPasswordValidator(String? value, String original) {
  if (value == null || value.isEmpty) return 'Please confirm your password';
  if (value != original) return 'Passwords do not match';
  return null;
}
