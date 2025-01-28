import 'package:flutter/material.dart';
import 'package:ghodaa/services/color.service.dart';

class PinVerifyingDialog extends StatefulWidget {
  final int pinLength;

  const PinVerifyingDialog({
    super.key,
    required this.pinLength,
  });

  @override
  _PinVerifyingDialogState createState() => _PinVerifyingDialogState();
}

class _PinVerifyingDialogState extends State<PinVerifyingDialog> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.pinLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _submitPin() {
    final enteredPin = _controllers.map((controller) => controller.text).join();
    Navigator.pop(context, enteredPin); // Pass the entered PIN back
  }

  void _onPinInputChange(int index) {
    if (_controllers[index].text.isNotEmpty) {
      if (index < widget.pinLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else if (_controllers.every((controller) => controller.text.isNotEmpty)) {
        _submitPin(); // Call the submit function when the last input is filled
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CupertinoAlertDialog();
    return AlertDialog(
      backgroundColor: ColorService().transparent,
      // title: const Text('Enter PIN', textAlign: TextAlign.center,),
      content: SizedBox(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 54,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (_) => _onPinInputChange(index),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
            );
          }),
        ),
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () => Navigator.pop(context), // Close the dialog
      //     child: const Text('Cancel'),
      //   ),
      // ],
      // actionsAlignment: MainAxisAlignment.center,
    );
  }
}

// Function to show the dialog with named parameters
Future<String?> showPinDialog({
  required BuildContext context,
  required int pinLength,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return PinVerifyingDialog(
        pinLength: pinLength,
      );
    },
  );
}
