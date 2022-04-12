import 'package:flutter/material.dart';
import 'matrix_gesture_detector.dart';
import 'dart:async';
import 'dart:math' as math;

// ignore: must_be_immutable
class ResizableWidget extends StatefulWidget {
  ResizableWidget({
    key,
    required this.position,
    required this.resizableWidget,
    this.canMove = true,
    this.showRemoveIcon = true,
    this.borderColor = Colors.black,
    this.widgetType,
    this.matrix4,
    this.isVisible = true,
    this.removeIcon = const Icon(
      Icons.close,
      size: 20.0,
    ),
    required this.onRemoveClick,
    required this.onSetTop,
    required this.onClick,
    required this.onTouchOver,
  }) : super(key: key);

  final int position;
  Widget resizableWidget;
  bool canMove;
  bool showRemoveIcon;
  Color borderColor;
  String? widgetType;
  Matrix4? matrix4;
  bool isVisible;
  final Icon removeIcon;

  /// return widget key and his position
  final Function(Key, int) onRemoveClick;

  /// return widget key, position and his type if you added
  final Function(Key, int, String?) onSetTop;

  /// return widget key, position and his type if you added
  final Function(Key, int, String?) onClick;

  /// return widget key, position and his matrix
  final Function(Key, int, Matrix4) onTouchOver;

  final resizableWidgetState = _ResizableWidgetState();

  @override
  // ignore: no_logic_in_create_state
  _ResizableWidgetState createState() => resizableWidgetState;

  void updateMatrix(Matrix4 matrix4) =>
      resizableWidgetState._setMatrix(matrix4);

  void updateView() {
    // ignore: invalid_use_of_protected_member
    resizableWidgetState.setState(() {});
  }

  double getX() => resizableWidgetState._getX();

  double getY() => resizableWidgetState._getY();

  double getAngle() => resizableWidgetState._getAngle();

  double getHeight() => resizableWidgetState._getHeight();

  double getWidth() => resizableWidgetState._getWidth();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  GlobalKey key = GlobalKey();

  Matrix4 matrix = Matrix4.identity();

  bool _isTouched = false;

  Timer? _timer;

  void _setMatrix(Matrix4 matrix4) {
    widget.matrix4 = matrix4;
    if (mounted) {
      setState(() {
        matrix = matrix4;
      });
    } else {
      matrix = matrix4;
    }
  }

  double _getX() {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return position.dx;
  }

  double _getY() {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return position.dy - 87.6;
  }

  double _getAngle() {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return -math.atan2(position.dy - 87.6, position.dx);
  }

  double _getWidth() {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    return box.size.width;
  }

  double _getHeight() {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    return box.size.height;
  }

  @override
  void initState() {
    super.initState();
    if (widget.matrix4 != null) {
      setState(() {
        matrix = widget.matrix4!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isVisible)
        ? Transform(
            transform: matrix,
            child: Stack(
              key: key,
              children: [
                MatrixGestureDetector(
                  onMatrixUpdate:
                      (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
                    setState(() {
                      if (widget.canMove) {
                        matrix = m;
                        widget.matrix4 = m;
                      }
                      if (!_isTouched) {
                        _isTouched = true;
                        widget.onSetTop(
                            widget.key!, widget.position, widget.widgetType);
                      }
                    });

                    if (_timer?.isActive ?? false) {
                      _timer?.cancel();
                      _timer = null;
                    }

                    _timer = Timer(const Duration(milliseconds: 600), () {
                      widget.onTouchOver(widget.key!, widget.position, m);
                      if (mounted) {
                        setState(() {
                          _isTouched = false;
                        });
                      }
                    });
                  },
                  focalPointAlignment: Alignment.center,
                  matrix4Old: matrix,
                  child: InkWell(
                    onTap: () {
                      debugPrint("click Top");
                      widget.onClick(
                          widget.key!, widget.position, widget.widgetType);
                      widget.onSetTop(
                          widget.key!, widget.position, widget.widgetType);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: widget.borderColor, width: 1.0),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: widget.resizableWidget,
                    ),
                  ),
                ),
                if (widget.showRemoveIcon)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: InkWell(
                      onTap: () {
                        widget.onRemoveClick(widget.key!, widget.position);
                      },
                      child: widget.removeIcon,
                    ),
                  ),
              ],
            ),
          )
        : Container();
  }
}
