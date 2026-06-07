abstract final class AlertTimeFormatter {
  static String relative(DateTime dateTime, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative || diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours} h';
    if (diff.inDays == 1) return 'Há 1 dia';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return 'Hoje';
  }
}
