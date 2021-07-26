import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/customWidgets.dart';
import 'package:provider/provider.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:aac_mobile/routes.dart';

class Signup extends StatefulWidget {
  String email;
  String password;
  String confirmPwd;
  String name;
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = new GlobalKey<FormState>();
  String _pwd1 = "";
  String _pwd2 = "";

  String _validatePwd(String pwd1, String pwd2) {
    const int minLen = 10;
    if(pwd1 == null || pwd1.length < minLen)
      return "Menos de ${minLen.toString()} Caracteres";
    if(pwd2 != null && pwd2.length >= minLen && pwd1 != pwd2)
      return "Las ontraseñas no coinciden";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthInterface>(context);

    final register = () async {
      final form = _formKey.currentState;
      if(form.validate()) {
        form.save();
        final response = await auth.signUp(widget.email, widget.password, name: widget.name, role: 'admin');
        if(response['status']) {
          User user = response['data'];
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          Navigator.pushReplacementNamed(context, RtName.pgLogin);
        } else {
          customMessage(context, "${response['message']}\n${response['data'].toString()}", "Vale");
        }
      } else
        customMessage(context, "Complete los datos indicados arriba", "Vale");
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Usuario"),
        backgroundColor:  const Color(0xff98B7D7),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0,),
                customField(
                  labelText: 'Nombre',
                  hintText: 'Ingrese su nombre y apellido',
                  icon: Icons.account_circle,
                  validator: (name) => name.isEmpty ? "El nombre no puede estar vacío" : null,
                  onSaved: (newName) => setState(() => widget.name = newName),
                ),
                SizedBox(height: 20.0,),
                customField(
                  labelText: 'Correo',
                  hintText: 'Ingrese el nuevo correo',
                  icon: Icons.email,
                  validator: (email) => email.isEmpty ? "Ingrese un correo válido" : null,
                  onSaved: (newMail) => setState(() => widget.email = newMail),
                ),
                SizedBox(height: 20.0,),
                customField(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese la nueva contraseña',
                  icon: Icons.lock,
                  obscure: true,
                  validator: (pwd) => _validatePwd(pwd, _pwd2),
                  onSaved: (pwd) => setState(() => widget.password = pwd),
                  onChanged: (pwd) => _pwd1 = pwd,
                ),
                SizedBox(height: 20.0,),
                customField(
                  labelText: 'Confirmar contraseña',
                  hintText: 'Vuelva a ingresar la contraseña',
                  icon: Icons.lock,
                  obscure: true,
                  validator: (pwd) => _validatePwd(pwd, _pwd1),
                  onSaved: (pwd) => setState(() => widget.confirmPwd = pwd),
                  onChanged: (pwd) => _pwd2 = pwd,
                ),
                SizedBox(height: 20.0,),
                auth.registeredInStatus == AuthStatus.Registering
                    ? loading("Registrando...")
                    : customButton('Registrar', onPressed: register,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
