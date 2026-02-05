extension ExtraStringExtensions on String {
  bool get isNullOrEmpty => trim().isEmpty;
  bool get isNotNullOrEmpty => trim().isNotEmpty;
}
