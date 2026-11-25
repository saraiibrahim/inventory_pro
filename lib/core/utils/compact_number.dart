String compactNumber(double value) {
  const units = ['', 'k', 'M', 'B'];
  var scaled = value.abs();
  var i = 0;
  while (scaled >= 1000 && i < units.length - 1) {
    scaled /= 1000;
    i++;
  }
  var text = scaled.toStringAsFixed(1);
  if (text == '1000.0' && i < units.length - 1) {
    text = '1.0';
    i++;
  }
  if (text.endsWith('.0')) text = text.substring(0, text.length - 2);
  return '${value < 0 ? '-' : ''}$text${units[i]}';
}
