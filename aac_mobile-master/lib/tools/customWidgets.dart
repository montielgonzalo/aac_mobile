import 'package:flutter/material.dart';

Widget customButton(String text, {void Function() onPressed, int color = 0xFF0000BF, int textColor = 0xFFFFFFFF}) {
  const TextStyle btnStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold,);
  return RaisedButton(
    elevation: 5,
    onPressed: onPressed,
    padding: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    color: Color(color),
    textColor: Color(textColor),
    child: Text(
      text,
      style: btnStyle,
    ),
  );
}

Widget customField({
  String labelText,
  String hintText,
  IconData icon,
  bool obscure = false,
  TextInputType keyboardType,
  String Function(String) validator,
  TextEditingController controller,
  void Function(String) onSaved,
  void Function(String) onChanged
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    keyboardType: keyboardType,
    obscureText: obscure,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator,
    onSaved: onSaved,
    onChanged: onChanged,
  );
}

void customMessage(BuildContext context, String content, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(content),
        action: SnackBarAction(
          label: label,
          onPressed: () {},
        ),
      )
  );
}

Widget loading(String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      CircularProgressIndicator(),
      SizedBox(width: 3.0,),
      Text(text),
    ],
  );
}

bool colorWhiteForeground(Color backgroundColor) =>
    1.05 / (backgroundColor.computeLuminance() + 0.05) > 4.5;
bool intWhiteForeground(int backgroundColor) =>
    colorWhiteForeground(Color(backgroundColor));
