import 'dart:ui';

String formatCurrency(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M ₫';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K ₫';
  return '${value.toStringAsFixed(0)} ₫';
}

String formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

Map<String, dynamic> _getStatusStyle(String status) {
  const map = {
    'pending': {'color': Color(0xFFBBDEFB)},
    'processing': {'color': Color(0xFFFFE0B2)},
    'shipped': {'color': Color(0xFFE1BEE7)},
    'delivered': {'color': Color(0xFFC8E6C9)},
    'cancelled': {'color': Color(0xFFFFCDD2)},
  };
  return map[status] ?? {'color': Color(0xFFEEEEEE)};
}
