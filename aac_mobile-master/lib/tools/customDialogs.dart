import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/customWidgets.dart';

Future<bool> decisionDialog(BuildContext context, String title,
    {String subtitle, IconData icon, String yes = "Yes", String no = "no"}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final List<Widget> content =
      icon != null || subtitle != null ? <Widget>[] : null;
      if (content != null) {
        if (icon != null) content.add(Icon(icon, size: 40));
        if (icon != null && subtitle != null) content.add(SizedBox(height: 16));
        if (subtitle != null) content.add(Text(subtitle));
      }
      return AlertDialog(
        elevation: 24.0,
        title: Text(title),
        content: content == null
            ? null
            : SingleChildScrollView(
          child: ListBody(
            children: content,
          ),
        ),
        actions: <Widget>[
          customButton(yes, color: 0xFFD9001B, onPressed: () {
            Navigator.of(context).pop(true);
          }),
          SizedBox(
            width: 16.0,
          ),
          customButton(no, onPressed: () {
            Navigator.of(context).pop(false);
          }),
        ],
      );
    },
  );
}

Future<double> numericDialog(BuildContext context, String title,
    {double initValue,
      String Function(double) validator,
      // IconData icon, // can't put non-constant icon
      String yes = "Yes",
      String no = "no"}) {
  double retVal;
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextFormField(
            initialValue: initValue == null ? null : initValue.toString(),
            decoration: const InputDecoration(
              // icon: Icon(icon), // can't put non-constant icon
              icon: Icon(Icons.apps),
              hintText: 'Ingrese el nuevo valor',
              labelText: 'Valor',
              border: OutlineInputBorder(),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String value) {
              retVal = double.tryParse(value);
              if (retVal == null) return 'Valor numérico inválido';
              if (validator != null) {
                String retStr = validator(retVal);
                if (retStr != null) {
                  retVal = null;
                  return retStr;
                }
              }
              return null;
            },
          ),
          actions: [
            customButton(yes, color: 0xFFD9001B, onPressed: () {
              if (retVal == null) return;
              Navigator.of(context).pop(retVal);
            },),
            customButton(no, onPressed: () {
              Navigator.of(context).pop();
            },),
          ],
        );
      });
}
