import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:aac_mobile/tools/dataService/primData.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:flutter/material.dart';
import 'package:aac_mobile/routes.dart';
import 'package:aac_mobile/tools/dataService/aqData.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:aac_mobile/tools/customWidgets.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<AqParams> aquariums = [];
  final ScrollController _scrollController = new ScrollController(); // set controller on scrolling
  bool _show = true;

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() => _show = false);
    }
    if (_scrollController.position.userScrollDirection ==  ScrollDirection.forward) {
      setState(() => _show = true);
    }
  }

  void _load(BuildContext context) {
    final ai = Provider.of<AuthInterface>(context, listen: false);
    ai.getResourceList().then((value) {
      if(value['status'] == true) {
        aquariums = value['data'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _load(context);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;
    final ai = Provider.of<AuthInterface>(context);

    final List<Widget> items = List.generate(aquariums.length, (index) => GestureDetector(
      onTap: () async {
        Provider.of<AqProvider>(context, listen: false).params = aquariums[index];
        // Settings the requester
        Map<String, PrimData> varsData = Operate().values;
        final di = Provider.of<DataInterface>(context, listen: false);
        di.init(varsData, '34iW-qOVVajaF3Tx7O59inl9xtjcCpp5', updatesOn: true, updatePer: 2);
        final deleted = await Navigator.pushNamed(context, RtName.pgAquarium);
        if (deleted == true) {
          _load(context);
        }
      },
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.all(16),
        decoration: new BoxDecoration(
          color: Color(aquariums[index].color),
          borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
          boxShadow: [
            new BoxShadow(
              color: Colors.black,
              offset: new Offset(3.0, 5.0),
              blurRadius: 8.0,
            )
          ],
        ),
        child: Center(
          child: Text(
            aquariums[index].name,
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,
                color: intWhiteForeground(aquariums[index].color)
                    ? Colors.white : Colors.black),),
        ),
      ),
    ));

    final img = Image.asset('assets/signup.jpg',fit: BoxFit.cover,);

    return Scaffold(
      backgroundColor: Color(0xffd3dde6),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Automatic Aquarium Care\nBienvenido ${user.name}!'),
            // automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            flexibleSpace: img,
            expandedHeight: 0.55 * MediaQuery.of(context).size.width,
          ),
          ChangeNotifierProvider<AuthInterface>.value(
            value: ai,
            child: SliverList(delegate: SliverChildListDelegate(ai.resStatus == ResourceStatus.Ready
                ? items
            : <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text((){
                    switch (ai.resStatus) {
                      case ResourceStatus.Connecting:
                        return "Connectando a db...";
                      case ResourceStatus.OpeningUsrInfo:
                        return "Obteniendo info de usuario...";
                      case ResourceStatus.GettingRes:
                        return "Obteniendo acuarios...";
                      default:
                        return "Error!!!";
                    }
                  }()),
                ],
              ),
            ],),),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: _show,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xff98B7D7),
          foregroundColor: Colors.black,
          onPressed: () async {
            final added = await Navigator.pushNamed(context, RtName.pgAddDevice);
            if (added == true) {
              _load(context);
            }
          },
          icon: Icon(Icons.add),
          label: Text(
              'Agregar Acuario',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}