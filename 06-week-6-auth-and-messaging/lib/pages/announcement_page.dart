import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  final String id;
  const AnnouncementPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman ID: $id')),
      body: Center(
        child: Text(
          'Detail Pengumuman #$id',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
