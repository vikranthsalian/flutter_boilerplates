extension DateTimeFormatting on DateTime {
  String get simpleDate => "${this.day}/${this.month}/${this.year}";
  String get simpleTime => "${this.hour}:${this.minute.toString().padLeft(2,'0')}";
  String get fullDateTime => "${this.simpleDate} ${this.simpleTime}";
}
