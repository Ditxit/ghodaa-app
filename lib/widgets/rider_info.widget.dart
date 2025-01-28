import 'package:flutter/material.dart';
import 'package:ghodaa/widgets/text.widgets.dart';

class CustomRiderInfo extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final String description;

  const CustomRiderInfo({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.description,
  });

  @override
  createState() => CustomRiderInfoState();
}

class CustomRiderInfoState extends State<CustomRiderInfo> {
  late String profileImageUrl;
  late String name;
  late String description;

  @override
  void initState() {
    profileImageUrl = widget.profileImageUrl;
    name = widget.name;
    description = widget.description;

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomText(
              text: '',
              marginTop: 12,
            ),
            CircleAvatar(
              backgroundColor: Colors.white70,
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 56.0,
              // child: Text('MG'),
            ),
            CustomText(
              text: name,
              fontColor: Colors.white,
              fontSize: 24,
              marginTop: 15,
            ),
            CustomText(
              text: description,
              fontColor: Colors.white70,
              fontSize: 14,
              marginTop: 0,
              marginBottom: 8,
            ),
          ],
        ),
      );

  void someMethod() {
    print(widget.name);
    setState(() => name = 'Testing Name');
  }
}
