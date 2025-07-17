import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/reading_model.dart';
import '../config/app_colors.dart';

class ReadingsPage extends StatefulWidget {
  const ReadingsPage({super.key});

  @override
  State<ReadingsPage> createState() => _ReadingsPageState();
}

class _ReadingsPageState extends State<ReadingsPage> {
  List<ReadingModel> readings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox<ReadingModel>('readings');
    setState(() {
      readings = box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اطلاعات ثبت شده'),
          backgroundColor: AppColors.primary,
        ),
        body: readings.isEmpty
            ? const Center(child: Text('هیچ اطلاعاتی ثبت نشده است.'))
            : ListView.builder(
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final r = readings[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('اشتراک: ${r.subscriptionNumber}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('موبایل: ${r.phone}'),
                    Text('توضیح: ${r.description}'),
                    Text('مکان: (${r.lat.toStringAsFixed(4)}, ${r.lng.toStringAsFixed(4)})'),
                    Text('تاریخ: ${r.createdAt.toString().substring(0, 19)}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
