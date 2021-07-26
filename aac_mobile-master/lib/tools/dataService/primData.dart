// Tipos de datos primitivos, para la comunicación entre partes del código y con otros procesos

enum dataType {
  boolT,
  intT,
  floatT,
  stringT
}

enum opType{
  read,
  write,
  readWrite
}

class PrimData {
  final dataType type;
  final opType op;
  final String id;
  final String name;
  var value;
  var lastValue;
  PrimData(this.type, this.op, this.id, this.name, {this.value, this.lastValue});
}
