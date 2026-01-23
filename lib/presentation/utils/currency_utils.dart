String currencySymbolFor(String currency) {
  switch (currency) {
    case 'BDT':
      return '৳';
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    default:
      return currency;
  }
}

String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
}
