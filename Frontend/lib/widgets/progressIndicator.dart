import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class CustomProgressIndicator extends StatefulWidget {
  final double size;
  const CustomProgressIndicator({super.key, this.size = 50});
  @override
  State<CustomProgressIndicator> createState() => _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.dotsTriangle(
      color: const Color(0xFF974061), size: widget.size
    );
  }
}
