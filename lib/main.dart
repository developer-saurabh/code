import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: OtpScreen()));
}

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  String _otpValue = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleOtpInput(String value, int index) {
    // Autofill or paste full OTP
    if (index == 0 && value.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = value[i];
      }
      _focusNodes[5].unfocus();
    }
    // Partial paste (2–5 digits)
    else if (index == 0 && value.length > 1 && value.length < 6) {
      for (int i = 0; i < value.length; i++) {
        _otpControllers[i].text = value[i];
      }
      _focusNodes[value.length].requestFocus();
    }
    // Single digit typed
    else if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    // Backspace
    else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Update OTP string
    setState(() {
      _otpValue = _otpControllers.map((e) => e.text).join();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter 6-digit OTP', style: TextStyle(fontSize: 20)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength:
                          index == 0 ? 6 : 1, // only first allows full paste
                      autofillHints:
                          index == 0 ? [AutofillHints.oneTimeCode] : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => _handleOtpInput(value, index),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                }),
              ),
              SizedBox(height: 30),
              Text('Current OTP: $_otpValue'),
            ],
          ),
        ),
      ),
    );
  }
}
