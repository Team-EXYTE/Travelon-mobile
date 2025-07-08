import 'package:flutter/material.dart';

/// A utility widget to wrap ListView.builder and similar widgets
/// to prevent the "Horizontal viewport was given unbounded height" error
class SafeScrollable extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const SafeScrollable({
    super.key,
    required this.child,
    this.heightFactor = 0.7,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      padding: padding,
      child: child,
    );
  }
}
