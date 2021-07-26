import 'primData.dart';
import 'package:flutter/foundation.dart';




class Operate {
  static const tempS = 'temp';
  static const phS = 'ph';
  static const ilumStS = 'ilumSt';
  static const calAqS = 'calAq';
  static const enfAqS = 'enfAq';
  static const onOffIlumS = 'onOffIlum';
  static const alimS = 'alim';

  final Map<String, PrimData> values = {
    tempS: PrimData(dataType.floatT, opType.read, 'V0', 'Temperatura'),
    phS: PrimData(dataType.floatT, opType.read, 'V1', 'PH'),
    ilumStS: PrimData(dataType.stringT, opType.read, 'V2', 'Estado Iluminación'),
    calAqS: PrimData(dataType.boolT, opType.readWrite, 'V4', 'Calentar'),
    enfAqS: PrimData(dataType.boolT, opType.readWrite, 'V5', 'Enfriar'),
    onOffIlumS: PrimData(dataType.boolT, opType.readWrite, 'V6', 'Iluminar/Apagar'),
    alimS: PrimData(dataType.boolT, opType.readWrite, 'V3', 'Alimentar'),
  };

  @override
  Operate({double temp, double ph, String ilumSt, bool calAq, bool enfAq, bool onOffIlum, bool alim}) {
    values[tempS].value = temp;
    values[phS].value = ph;
    values[ilumStS].value = ilumSt;
    values[calAqS].value = calAq;
    values[enfAqS].value = enfAq;
    values[onOffIlumS].value = onOffIlum;
    values[alimS].value = alim;
  }

  factory Operate.fromJson(Map<String, dynamic> json) {
    Operate res = new Operate();
    res.values.forEach((key, value) {
      //TODO: make type validations
      value.value = json[key];
    });
    return res;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    values.forEach((key, value) {
      json[key] = value.value;
    });
    return json;
  }

  //Map<String, dynamic> verify(PrimDataMap other) {}
  static Map<String, dynamic> verifyS(Operate params) {
    if(params == null) return null;
    Map<String, dynamic> json = {};
    params.values.forEach((key, value) {
      if(value.value != null)
        json[key] = value.value;
    });
    return json.isEmpty ? null : json;
  }
}


class History {
  static const promHrsAlimS = 'promHrsAlim';
  static const promTempS = 'promTemp';
  static const promIlumS = 'ilumSt';
  static const promPHS = 'promPH';

  final Map<String, PrimData> values = {
    promHrsAlimS: PrimData(dataType.intT, opType.read, 'V0', 'Alimentación'),
    promTempS: PrimData(dataType.intT, opType.read, 'V0', 'Temperatura'),
    promIlumS: PrimData(dataType.intT, opType.read, 'V1', 'Iluminación'),
    promPHS: PrimData(dataType.stringT, opType.read, 'V2', 'PH'),
  };

  @override
  History({int promHrsAlim, int promTemp, int promIlum, int promPH}) {
    values[promHrsAlimS].value = promHrsAlim;
    values[promTempS].value = promTemp;
    values[promIlumS].value = promIlum;
    values[promPHS].value = promPH;
  }

  factory History.fromJson(Map<String, dynamic> json) {
    History res = new History();
    res.values.forEach((key, value) {
      //TODO: make type validations
      value.value = json[key];
    });
    return res;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    values.forEach((key, value) {
      json[key] = value.value;
    });
    return json;
  }

  //Map<String, dynamic> verify(History other) {}
  static Map<String, dynamic> verifyS(History params) {
    if(params == null) return null;
    Map<String, dynamic> json = {};
    params.values.forEach((key, value) {
      if(value.value != null)
        json[key] = value.value;
    });
    return json.isEmpty ? null : json;
  }
}


class AqParams {
  //Principales
  String uuid;
  String name;
  int color;
  //Operacionales
  Operate op;
  //Históricos
  History hs;

  AqParams({@required this.uuid, this.name, this.color, this.op, this.hs}) {
    op ??= Operate();
    hs ??= History();
  }

 /* static AqParams byUUID(String uuid) {
    for(AqParams item in acuarios) {
      if (item.uuid == uuid)
        return item;
    }
    return null;
  }*/

  factory AqParams.fromJson(Map<String, dynamic> json) => new AqParams(
      name: json['name'],
      uuid: json['uuid'],
      color: json['color'],
      op: Operate.fromJson(json['op']),
      hs: History.fromJson(json['hs'])
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'uuid': uuid,
    'color': color,
    'op': op.toJson(),
    'hs': hs.toJson()
  };

  //Map<String, dynamic> verify(AqParams other) {}
  static Map<String, dynamic> verifyS(AqParams params) {
    if((params) == null) return null;
    Map<String, dynamic> res = {};
    if(params.name != null) res['name'] = params.name;
    if(params.uuid != null) res['uuid'] = params.uuid;
    if(params.color != null) res['color'] = params.color;
    Map<String, dynamic> opres = Operate.verifyS(params.op);
    if(opres != null) res.addAll(opres);
    Map<String, dynamic> hsres = History.verifyS(params.hs);
    if(hsres != null) res.addAll(hsres);
    return res.isEmpty ? null : res;
  }
}


/*List<AqParams> acuarios = [
  AqParams(
      uuid: "AQ-0c0f22a2-5991-4705-b486-83f859a8a278",
      name: 'Fondo de Bikini',
      color: 0xFF043353,
      op: Operate(temp: 28.0, ph: 6, ilumSt: "APAGADO", calAq: false, enfAq: false, onOffIlum: false, alim: false),
      hs: History(promHrsAlim: 4, promTemp: 28, promIlum: 8, promPH: 6)
  ),
  AqParams(
      uuid: "AQ-27e026f6-4347-4595-a514-836756e0afec",
      name: 'Fondo de Botana',
      color: 0xFF6C98C6,
      op: Operate(temp: 28.0, ph: 8, ilumSt: "APAGADO", calAq: false, enfAq: false, onOffIlum: false, alim: false),
      hs: History(promHrsAlim: 4, promTemp: 28, promIlum: 8, promPH: 6),
  )
];*/


class AqProvider with ChangeNotifier {
  AqParams _prms = AqParams();
  void Function(Map<String, dynamic> m) _changesCb;

  AqParams get params => _prms;

  set params(AqParams user) {
    _prms = user;
    notifyListeners();
  }

  void notifyChanges(Function(Map<String, dynamic>) cb) => _changesCb = cb;

  set modifyAction(AqParams prm) {
    Map<String, dynamic> modified = AqParams.verifyS(prm);
    if(_changesCb != null) _changesCb(modified);
  }
}