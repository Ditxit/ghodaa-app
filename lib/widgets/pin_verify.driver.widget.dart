import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinVerifyingSheet extends StatefulWidget {
  final String correctPin;
  final VoidCallback onSuccess;

  PinVerifyingSheet({
    required this.correctPin,
    required this.onSuccess,
  });

  @override
  _PinVerifyingSheetState createState() => _PinVerifyingSheetState();
}

class _PinVerifyingSheetState extends State<PinVerifyingSheet> {
  late final int _pinLength;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _pinLength = widget.correctPin.length;

    for (int i = 0; i < _pinLength; i++) {
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

  void _verifyPin() {
    final enteredPin = _controllers.map((controller) => controller.text).join();
    if (enteredPin == widget.correctPin) {
      setState(() {
        _isVerified = true;
      });
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      setState(() {
        _isVerified = false;
        _clearPin();
      });
    }
  }

  void _clearPin() {
    for (var controller in _controllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  void _onPinInputChange(int index) {
    if (_controllers[index].text.isNotEmpty) {
      if (index < _pinLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else if (_controllers
          .every((controller) => controller.text.isNotEmpty)) {
        _verifyPin();
      }
    }
  }

  void _onPinBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isVerified ? 'PIN Verified!' : 'Enter PIN',
            style: TextStyle(
              fontSize: 20,
              color: _isVerified ? Colors.green : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_pinLength, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        _onPinBackspace(index);
                      }
                    },
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black, // Set text color to black for visibility
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      onChanged: (_) => _onPinInputChange(index),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (!_isVerified &&
              _controllers.any((controller) => controller.text.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Incorrect PIN. Please try again.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
