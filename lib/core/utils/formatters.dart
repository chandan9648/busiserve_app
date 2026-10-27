/// Small, dependency-free formatters (no intl needed for these).
class Formatters {
  Formatters._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String date(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  static String dateTime(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final m = l.minute.toString().padLeft(2, '0');
    return '${date(l)}, $h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
  }

  static String relative(DateTime? d, {DateTime? now}) {
    if (d == null) return '';
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return date(d);
  }

  /// Indian digit grouping: 1234567.5 -> ₹12,34,567.50
  static String currency(double amount, {String currency = 'INR'}) {
    final symbol = currency == 'INR' ? '₹' : '$currency ';
    final negative = amount < 0;
    final fixed = amount.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    var whole = parts[0];
    final decimals = parts[1];
    if (currency == 'INR' && whole.length > 3) {
      final last3 = whole.substring(whole.length - 3);
      var rest = whole.substring(0, whole.length - 3);
      final groups = <String>[];
      while (rest.length > 2) {
        groups.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) groups.insert(0, rest);
      whole = '${groups.join(',')},$last3';
    } else {
      whole = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    }
    final value = decimals == '00' ? whole : '$whole.$decimals';
    return '${negative ? '-' : ''}$symbol$value';
  }
}
