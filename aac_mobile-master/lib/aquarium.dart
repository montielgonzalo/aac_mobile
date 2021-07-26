import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aac_mobile/tools/dataService/aqData.dart';
import 'package:flutter/rendering.dart';
import 'package:aac_mobile/tools/customWidgets.dart';
import 'package:aac_mobile/tools/customDialogs.dart';
import 'package:provider/provider.dart';

class Aquarium extends StatefulWidget {

  @override
  _AquariumState createState() => _AquariumState();
}

class _AquariumState extends State<Aquarium> {

  DataInterface di;
  AqProvider aquarium;
  int _selIndex = 0;
  ScrollController _scrollController = new ScrollController(); // set controller on scrolling
  bool _show = true;

  void scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() => _show = false);
    }
    if (_scrollController.position.userScrollDirection ==  ScrollDirection.forward) {
      setState(() => _show = true);
    }
  }

  void diListener () {
    Map<String, dynamic> resp = di.values;
    Map<String, dynamic> aqJson = aquarium.params.toJson();
    resp.forEach((key, value) => aqJson['op'][key] = value);
    print(aqJson);
    aquarium.params = AqParams.fromJson(aqJson);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
    // para hacer llamadas de Provider.of() fuera del builder
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      aquarium = Provider.of<AqProvider>(context, listen: false);
      di = Provider.of<DataInterface>(context, listen: false);
      aquarium.notifyChanges((changed) => di.values = changed);
      di.addListener(diListener);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    if (di != null) {
      di.removeListener(diListener);
      di.updates = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AqProvider aquarium = Provider.of<AqProvider>(context);
    final ai = Provider.of<AuthInterface>(context);

    /*final List<Widget> _widgetOptions = <Widget>[
      AqRtData(),
      AqHist(),
    ];*/

    return Scaffold(
      backgroundColor: Color(aquarium.params.color),
      appBar: AppBar(
        title: Text(aquarium.params.name),
        backgroundColor:  const Color(0xff98B7D7),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        //child: _widgetOptions.elementAt(_selIndex),
        child: AqRtData(),
      ),
      floatingActionButton: Visibility(
        visible: _show,
        child: FloatingActionButton.extended(
          backgroundColor: Color(0xFFD9001B),
          foregroundColor: Colors.white,
          onPressed: ai.resStatus != ResourceStatus.Ready ? null : () async {
            bool response = await decisionDialog(context, "¡ATENCIÓN!",
              subtitle: '¿Está seguro que desea eliminar este acuario permanentemente?',
              icon: Icons.warning,
              yes: 'Aceptar',
              no: 'Cancelar',
            );
            if (response) {
              final response = await ai.deleteResource(aquarium.params.uuid);
              if(response['status']) {
                Navigator.pop(context, true);
              } else {
                customMessage(context, response['message'].toString(), "Vale");
              }
            }
          },
          icon: Icon(Icons.delete),
          label: ChangeNotifierProvider<AuthInterface>.value(
            value: ai,
            child: ai.resStatus == ResourceStatus.Ready
              ? Text('Eliminar Acuario', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),)
              : loading('Eliminando...'),
          ),
        ),
      ),
      /*bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.panorama_fisheye), label: 'Acuario'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Histórico'),
        ],
        currentIndex: _selIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => setState(() {
          _selIndex = index;
        }),
      ),*/
    );
  }
}


//class AqRtData extends StatelessWidget {
class AqRtData extends StatefulWidget {

  @override
  _AqRtData createState() => _AqRtData();
}

class _AqRtData extends State<AqRtData> {
  AqProvider aquarium;
  bool firstFrame;

  int alimEstado = 0;
  bool estadoLuz = false;
  int calentarEstado = 0;
  int enfriarEstado = 0;

  void aqExtListener() {
    bool ilumAction = aquarium.params.op.values[Operate.onOffIlumS].value;
    //estado inicial
    if (firstFrame) {
      setState(() {
        estadoLuz = ilumAction;
      });
      firstFrame = false;
    }
    // evaluando estado del alimentador
    bool alimSt = aquarium.params.op.values[Operate.alimS].value;
    switch (alimEstado) {
      case 1:
        if(alimSt) {
          Timer(Duration(seconds: 10), () {
            aquarium.modifyAction = AqParams()..op.values[Operate.alimS].value = false;
            setState(() => alimEstado = 3);
          });
          setState(() => alimEstado = 2);
        }
        break;
      case 3:
        if(!alimSt) {
          setState(() => alimEstado = 0);
        }
        break;
    }
    // evaluando estado del calentador
    bool calentar = aquarium.params.op.values[Operate.calAqS].value;
    switch (calentarEstado) {
      case 1:
        if(calentar) {
          Timer(Duration(seconds: 10), () {
            //aquarium.modifyAction = AqParams()..op.values[Operate.calAqS].value = false;
            //setState(() => calentarEstado = 3);
            setState(() => calentarEstado = 0);
          });
          setState(() => calentarEstado = 2);
        }
        break;
      //case 3:
        //if(!calentar) {
          //setState(() => calentarEstado = 0);
        //}
        //break;
    }
    // evaluando estado del enfriador
    bool enfriar = aquarium.params.op.values[Operate.enfAqS].value;
    switch (enfriarEstado) {
      case 1:
        if(enfriar) {
          Timer(Duration(seconds: 10), () {
            //aquarium.modifyAction = AqParams()..op.values[Operate.enfAqS].value = false;
            //setState(() => enfriarEstado = 3);
            setState(() => enfriarEstado = 0);
          });
          setState(() => enfriarEstado = 2);
        }
        break;
      //case 3:
        //if(!enfriar) {
          //setState(() => enfriarEstado = 0);
        //}
        //break;
    }
  }

  @override
  void initState() {
    super.initState();
    firstFrame = true;
    // para hacer llamadas de Provider.of() fuera del builder
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      aquarium = Provider.of<AqProvider>(context, listen: false);
      aquarium.modifyAction = AqParams()..op.values[Operate.alimS].value = false;
      //aquarium.modifyAction = AqParams()..op.values[Operate.calAqS].value = false;
      //aquarium.modifyAction = AqParams()..op.values[Operate.enfAqS].value = false;
      aquarium.addListener(aqExtListener);
    });
  }

  @override
  void dispose() {
    if (aquarium != null) {
      aquarium.removeListener(aqExtListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //AqProvider aquarium = Provider.of<AqProvider>(context);
    aquarium = Provider.of<AqProvider>(context);
    const TextStyle ttlStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    const TextStyle subttlStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.normal);
    double temp = aquarium.params.op.values[Operate.tempS].value;
    double ph = aquarium.params.op.values[Operate.phS].value;
    //String ilumFb = aquarium.params.op.values[Operate.ilumStS].value;
    bool calentar = aquarium.params.op.values[Operate.calAqS].value;
    bool enfriar = aquarium.params.op.values[Operate.enfAqS].value;
    bool ilumAction = aquarium.params.op.values[Operate.onOffIlumS].value;
    //bool alimSt = aquarium.params.op.values[Operate.alimS].value;

    return ChangeNotifierProvider<AqProvider>.value(
      value: aquarium,
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            elevation: 10,
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  tileColor: Theme.of(context).secondaryHeaderColor.withAlpha(20),
                  title: Text(aquarium.params.op.values[Operate.alimS].name, style: ttlStyle,),
                  //subtitle: Text(alimSt ? "ALIMENTANDO" : "NO ALIMENTANDO", style: subttlStyle,),
                  trailing: Icon(Icons.fastfood),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    alimEstado != 0
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(width: 10.0,),
                              Text(alimEstado == 1 ? "Encendiendo" :
                                alimEstado == 2 ? "Alimentando" :
                                "Apagando", style: subttlStyle,),
                            ]
                          )
                        //: customButton(alimSt ? "No alimentar" : 'Alimentar', onPressed: () {
                        : customButton('Alimentar', onPressed: () {
                            setState(() => alimEstado = 1);
                            //aquarium.modifyAction = AqParams()..op.values[Operate.alimS].value = !alimSt;
                            aquarium.modifyAction = AqParams()..op.values[Operate.alimS].value = true;
                          }),
                    /*customButton('Programar', onPressed: () async {
                      final TimeOfDay freq = await showTimePicker(
                        context: context,
                        helpText: 'Frecuencia',
                        initialTime: TimeOfDay(hour: 1, minute: 0),
                      );
                      if (freq == null) return;
                      final TimeOfDay init = await showTimePicker(
                        context: context,
                        helpText: 'Iniciar',
                        initialTime: TimeOfDay(hour: 6, minute: 0),
                      );}),*/
                  ],
                ),
                SizedBox(height: 10.0,),
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            elevation: 10,
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  tileColor: Theme.of(context).secondaryHeaderColor.withAlpha(20),
                  title: Text('Iluminación', style: ttlStyle,),
                  //subtitle: Text(ilumFb, style: subttlStyle,),
                  subtitle: Text(ilumAction ? 'ENCENDIDO' : 'APAGADO', style: subttlStyle,),
                  trailing: Icon(Icons.lightbulb),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    estadoLuz != ilumAction
                        ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(width: 10.0,),
                          Text(ilumAction ? "APAGANDO..." : "ENCENDIENDO...", style: subttlStyle,),
                        ]
                    )
                        : customButton(ilumAction ? 'Apagar' : 'Encender', onPressed: () {
                      aquarium.modifyAction = AqParams()..op.values[Operate.onOffIlumS].value = !ilumAction;
                      setState(() {
                        estadoLuz = !ilumAction;
                      });
                    }),
                    /*customButton('Programar', onPressed: () async {
                      final TimeOfDay freq = await showTimePicker(
                        context: context,
                        helpText: 'Frecuencia',
                        initialTime: TimeOfDay(hour: 1, minute: 0),
                      );
                      if (freq == null) return;
                      final TimeOfDay init = await showTimePicker(
                        context: context,
                        helpText: 'Iniciar',
                        initialTime: TimeOfDay(hour: 6, minute: 0),
                      );
                    }),*/
                  ],
                ),
                SizedBox(height: 10.0,),
              ],
            ),
          ),Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            elevation: 10,
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  tileColor: Theme.of(context).secondaryHeaderColor.withAlpha(20),
                  title: Text('Temperatura', style: ttlStyle,),
                  subtitle: Text(temp.toString() + '° C', style: subttlStyle,),
                  trailing: Icon(Icons.thermostat_outlined),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calentarEstado != 0
                        ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(width: 10.0,),
                          Text(calentarEstado == 1 ? "Encendiendo" :
                          calentarEstado == 2 ? "Calentando" :
                          "Apagando", style: subttlStyle,),
                        ]
                    )
                    //: customButton(calentar ? 'No calentar' : 'Calentar', onPressed: () {
                        : customButton('Calentar', onPressed: () {
                          if (calentar) {
                            setState(() => calentarEstado = 2);
                            Timer(Duration(seconds: 10), () {
                              setState(() => calentarEstado = 0);
                            });
                          } else {
                            setState(() => calentarEstado = 1);
                          }
                          //aquarium.modifyAction = AqParams()..op.values[Operate.calAqS].value = !calentar;
                          aquarium.modifyAction = AqParams()..op.values[Operate.calAqS].value = true;
                        }),
                    enfriarEstado != 0
                        ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(width: 10.0,),
                          Text(enfriarEstado == 1 ? "Encendiendo" :
                          enfriarEstado == 2 ? "Enfriando" :
                          "Apagando", style: subttlStyle,),
                        ]
                    )
                    //: customButton(enfriar ? 'No enfriar' : 'enfriar', onPressed: () {
                        : customButton('Enfriar', onPressed: () {
                          if (enfriar) {
                            setState(() => enfriarEstado = 2);
                            Timer(Duration(seconds: 10), () {
                              setState(() => enfriarEstado = 0);
                            });
                          } else {
                            setState(() => enfriarEstado = 1);
                          }
                          //aquarium.modifyAction = AqParams()..op.values[Operate.enfAqS].value = !enfriar;
                          aquarium.modifyAction = AqParams()..op.values[Operate.enfAqS].value = true;
                    }),
                  ],
                ),
                SizedBox(height: 10.0,),
              ],
            ),
          ),Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(16),
            elevation: 10,
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  tileColor: Theme.of(context).secondaryHeaderColor.withAlpha(20),
                  title: Text('PH', style: ttlStyle,),
                  subtitle: Text(ph.toString(), style: subttlStyle,),
                  trailing: Icon(Icons.soap),
                ),
                Text(ph < 7 ? 'ÁCIDO' : ph > 7 ? 'BÁSICO' : 'NEUTRO', style: subttlStyle,),
                SizedBox(height: 10.0,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*class AqHist extends StatelessWidget {
  static const TextStyle _ttlStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const TextStyle _subttlStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    AqProvider aquarium = Provider.of<AqProvider>(context);
    return Column(
      children: [
        customCard(context, 'Alimentación', aquarium.params.hs.values[History.promHrsAlimS].value.toString() + 'hs.', 'Horas promedio último mes', Icons.fastfood),
        customCard(context, 'Temperatura', aquarium.params.hs.values[History.promTempS].value.toString() + '° C', 'Grados promedio último mes', Icons.thermostat_outlined),
        customCard(context, 'Iluminación', aquarium.params.hs.values[History.promIlumS].value.toString() + 'hs.', 'Valor promedio último mes', Icons.lightbulb),
        customCard(context, 'PH', aquarium.params.hs.values[History.promPHS].value.toString(), 'PH promedio último mes', Icons.soap),
      ],
    );
  }

  Widget customCard(BuildContext context, String title, String value, String description, IconData iconData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(16),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            tileColor: Theme.of(context).secondaryHeaderColor.withAlpha(20),
            title: Text(title, style: _ttlStyle,),
            subtitle: Text(value, style: _subttlStyle,),
            trailing: Icon(iconData),
          ),
          Text(description, style: _ttlStyle,),
          SizedBox(height: 10.0,),
        ],
      ),
    );
  }
}*/
