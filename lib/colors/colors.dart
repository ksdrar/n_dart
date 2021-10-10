String _dye<T>(String color, T input) {
  return "$color$input\u001b[0m";
}

String black<T>(T input) {
  return _dye("\u001b[30m", input);
}

String red<T>(T input) {
  return _dye("\u001b[31m", input);
}

String green<T>(T input) {
  return _dye("\u001b[32m", input);
}

String yellow<T>(T input) {
  return _dye("\u001b[33m", input);
}

String blue<T>(T input) {
  return _dye("\u001b[34m", input);
}

String magenta<T>(T input) {
  return _dye("\u001b[35m", input);
}

String cyan<T>(T input) {
  return _dye("\u001b[36m", input);
}

String white<T>(T input) {
  return _dye("\u001b[37m", input);
}
