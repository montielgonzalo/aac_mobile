import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/customWidgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class AddDevice extends StatefulWidget {
  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final _formKey = new GlobalKey<FormState>();
  Color color = const Color(0xff98B7D7);
  final txt = TextEditingController();
  String name;
  String uuid;

  @override
  Widget build(BuildContext context) {
    final ai = Provider.of<AuthInterface>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Nuevo Dispositivo", style: TextStyle(
            color: useWhiteForeground(color) ? Colors.white : Colors.black
        ),),
        backgroundColor:  color,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 25.0,),
                //Row(
                  //children: [
                    customField(
                      labelText: "UUID",
                      hintText: "Ingresar identificador de dispositivo",
                      icon: Icons.code,
                      validator: (value) => value.isEmpty ? "Falta identificador" : null,
                      onSaved: (value) => uuid = value,
                      controller: txt,
                    ),
                    SizedBox(height: 5.0,),
                    customButton("Abrir QR", onPressed: () async {
                      String scanRes = await FlutterBarcodeScanner.scanBarcode(
                          "#ff6666", "Cancelar", false, ScanMode.QR);
                      if(scanRes.length > 2) {
                        txt.value = TextEditingValue(
                          text: scanRes,
                          selection: TextSelection.fromPosition(TextPosition(offset: scanRes.length),),
                        );
                      }
                    }),
                  //],
                //),
                SizedBox(height: 20.0,),
                customField(
                  labelText: "Nombre",
                  hintText: "Nuevo Nombre del dispositivo",
                  icon: Icons.keyboard_rounded,
                  validator: (value) => value.isEmpty ? "Necesita un nombre" : null,
                  onSaved: (value) => name = value,
                ),
                SizedBox(height: 20.0,),
                Center(
                  child: customButton( "Seleccone el color",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Color tempColor = color;
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0.0),
                            contentPadding: const EdgeInsets.all(0.0),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  MaterialPicker(
                                    pickerColor: color,
                                    onColorChanged: (newColor) => setState(() => tempColor = newColor),
                                    enableLabel: true,
                                  ),
                                  SizedBox(height: 5.0,),
                                  Row(
                                    children: [
                                      SizedBox(width: 5.0,),
                                      customButton( "Aceptar",
                                        onPressed: () {
                                          setState(() => color = tempColor);
                                          Navigator.pop(context);
                                        },
                                        //color: tempColor.value,
                                        //textColor: useWhiteForeground(tempColor) ? 0xffffffff : 0xff000000,
                                      ),
                                      SizedBox(width: 20.0,),
                                      customButton( "Cancelar",
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        color: color.value,
                                        textColor: useWhiteForeground(color) ? 0xffffffff : 0xff000000,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0,),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    color: color.value,
                    textColor: useWhiteForeground(color) ? 0xffffffff : 0xff000000,
                  ),
                ),
                SizedBox(height: 20.0,),
                ChangeNotifierProvider<AuthInterface>.value(
                  value: ai,
                  child: ai.resStatus == ResourceStatus.Ready
                      ? customButton("Agregar dispositivo", onPressed: () async {
                        final form = _formKey.currentState;
                        if(form.validate()) {
                          form.save();
                          final response = await ai.addResource(name, uuid, color: color.value);
                          if(response['status']) {
                            Navigator.pop(context, true);
                          } else {
                            customMessage(context, response['message'].toString(), "Vale");
                          }
                        } else {
                          customMessage(context, "Complete los campo(s) de arriba", "Vale");
                        }
                      })
                      : loading("agregando base de datos"),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}