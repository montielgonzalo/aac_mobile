import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:flutter/material.dart';
import 'package:aac_mobile/routes.dart';
import 'package:provider/provider.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:aac_mobile/tools/customWidgets.dart';
import 'package:aac_mobile/tools/commService/service.dart';

class LoginScreen extends StatefulWidget {

  String user;
  String password;
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthInterface>(context);
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.height;

    final logging = () async {
      final form = _formKey.currentState;
      if(form.validate()) {
        form.save();
        final response = await auth.signIn(widget.user, widget.password);
        if(response['status']) {
          User user = response['user'];
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          Navigator.pushReplacementNamed(context, RtName.pgMenu);
        } else {
          customMessage(context, response['message'].toString(), "Vale");
        }
      } else
        customMessage(context, "Campo(s) de arriba Inválido(s)", "Vale");
    };

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width,
                height: height*0.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/signup.jpg',fit: BoxFit.fill,),
                    Container(
                      alignment: Alignment.center,
                        child: Text('Automatic Aquarium Care',style: TextStyle(color: Color(0xffD3DDE6), fontSize: 25.0,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Iniciar Sesión',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 30.0,),
                      customField(
                        labelText: 'Correo',
                        hintText: 'Ingrese su correo',
                        icon: Icons.email,
                        validator: (email) => email.isEmpty ? "Ingrese un correo válido" : null,
                        onSaved: (email) => widget.user = email,
                      ),
                      SizedBox(height: 20.0,),
                      customField(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña',
                        icon: Icons.lock,
                        obscure: true,
                        validator: (pwd) => pwd.isEmpty ? "Ingrese una contraseña válida" : null,
                        onSaved: (pwd) => widget.password = pwd,
                      ),
                      SizedBox(height: 30.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /*FlatButton(
                            child: Text('Olvidó la contraseña?',style: TextStyle(fontSize: 12.0),),
                            onPressed: () => print("Forgot password pressed"),
                          ),*/
                          auth.loggedInStatus == AuthStatus.Authenticating
                              ? loading("Autenticando...")
                              : customButton('Iniciar', onPressed: logging,),
                        ],
                      ),
                      SizedBox(height:20.0),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, RtName.pgSignup);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: '¿No tienes cuenta? ',
                            children: [
                              TextSpan(
                                text: 'Registrarse',
                                style: TextStyle(
                                    color: Color(0xffEE7B23)
                                ),
                              ),
                            ]
                          ),
                        ),
                      ),
                      SizedBox(height:20.0),
                      /*customField(
                        labelText: "Url",
                        hintText: "(Opcional) Escriba Url del dispositivo",
                        icon: Icons.alternate_email,
                        onChanged: (text) {
                          if(text.isNotEmpty) {
                            AppUrl.changeBaseUrl(text);
                          }
                        },
                      ),*/
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}