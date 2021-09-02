import 'package:flutter/material.dart';

class Manual extends StatelessWidget {
  const Manual({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual'),
      ),
      body: Center(
        child: Text('Manual'),
      ),
    );
  }
}
