import 'package:flutter/material.dart';

/// Wrapper widget that keeps tab content alive when switching tabs.
/// This preserves scroll position and widget state.
class KeepAliveTab extends StatefulWidget {
  const KeepAliveTab({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
