import 'dart:convert';

import 'package:flutter/material.dart';

import 'dua_model.dart';

class DuaList extends StatelessWidget {
  List<DuaModel> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<DuaModel>((json) => new DuaModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz'),
      ),
      body: Center(
        child: Container(
            child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/quran/dua_list.json'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            print(snapshot.data);

            List<DuaModel> dua = parseJosn(snapshot.data.toString());

            return ListView.separated(
              itemCount: dua.length,
              separatorBuilder: (context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(
                    thickness: 2.0,
                  ),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () => print('fffff'),
                  leading: Container(
                    height: 40,
                    width: 40,
                    child: Stack(
                      children: [
                        ImageIcon(
                          AssetImage('assets/ayyah_icon.png'),
                          size: 40,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Center(child: Text((index + 1).toString()))),
                      ],
                    ),
                  ),
                  title: Column(
                    children: [
                      Text(
                        dua[index].dua,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.green, fontSize: 20.0),
                      ),
                      Text(dua[index].translation),
                    ],
                  ),
                  subtitle: Text(
                    dua[index].reference,
                    textDirection: TextDirection.rtl,
                  ),
                );
              },
            );
          },
        )),
      ),
    );
  }
}
