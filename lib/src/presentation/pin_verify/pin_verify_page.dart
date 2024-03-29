import 'package:flutter/material.dart';
import 'package:rbh_task_management/main.dart';
import 'package:rbh_task_management/src/core/session_manager.dart';
import 'package:rbh_task_management/src/presentation/task_list/task_list_page.dart';

enum PinState { normal, incorrect }

class PinVerifyPage extends StatefulWidget {
  const PinVerifyPage({super.key});
  static const routeName = '/pin_verify';

  @override
  State<StatefulWidget> createState() => _PinVerifyPageState();
}

class _PinVerifyPageState extends State<PinVerifyPage> {
  List<String> pin = [];
  PinState _pinState = PinState.normal;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.125,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      _getPinHeader(),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: PinDisplay(
                    pinLength: pin.length,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: GridView.count(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      crossAxisCount: 3,
                      children: List.generate(
                        12,
                        (index) {
                          int pinNumber = index + 1;
                          switch (pinNumber) {
                            case >= 1 && <= 9:
                              return NumpadButton(
                                number: pinNumber,
                                onPressed: () => _addPin(pinNumber),
                              );
                            case 10:
                              return const SizedBox();
                            case 11:
                              pinNumber = 0;
                              return NumpadButton(
                                number: pinNumber,
                                onPressed: () => _addPin(pinNumber),
                              );
                            case 12:
                              return NumpadButton(
                                number: -1,
                                isBackSpace: true,
                                onPressed: () {
                                  setState(() {
                                    if (pin.isNotEmpty) pin.removeLast();
                                  });
                                },
                              );
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addPin(int pinNumber) {
    if (pin.length >= 6) return;
    setState(() {
      _pinState = PinState.normal;
      pin.add(pinNumber.toString());
    });
    if (pin.length == 6) {
      _onPinComplete();
    }
  }

  void _onPinComplete() {
    final result = getIt<SessionManager>().onPinEntered(pin);
    if (result == true) {
      Navigator.of(context).pushReplacementNamed(TaskListPage.routeName);
    } else {
      setState(() {
        _pinState = PinState.incorrect;
        pin.clear();
      });
    }
  }

  String _getPinHeader() {
    switch (_pinState) {
      case PinState.normal:
        return "Input your PIN";
      case PinState.incorrect:
        return "Incorrect Pin\nPlease try again";
    }
  }
}

class NumpadButton extends StatelessWidget {
  final int number;
  final VoidCallback onPressed;
  final bool? isBackSpace;

  const NumpadButton({
    super.key,
    required this.number,
    required this.onPressed,
    this.isBackSpace,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: isBackSpace == true
          ? const Icon(Icons.backspace)
          : Text(number.toString()),
    );
  }
}

class PinDisplay extends StatelessWidget {
  final int pinLength;

  const PinDisplay({
    super.key,
    required this.pinLength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            color: index < pinLength ? Colors.deepPurple : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
