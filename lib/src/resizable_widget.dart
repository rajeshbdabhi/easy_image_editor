import 'package:flutter/material.dart';
import 'matrix_gesture_detector.dart';
import 'dart:async';

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
    this.removeIcon = const Icon(Icons.close,size: 20.0,),
    required this.onRemoveClick,
    required this.onSetTop,
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

  /// return widget key, position and his matrix
  final Function(Key, int, Matrix4) onTouchOver;

  final resizableWidgetState = _ResizableWidgetState();

  @override
  _ResizableWidgetState createState() => resizableWidgetState;

  void updateMatrix(Matrix4 matrix4) =>
      resizableWidgetState._setMatrix(matrix4);

  void updateView() {
    resizableWidgetState.setState(() {});
  }
}

class _ResizableWidgetState extends State<ResizableWidget> {
  GlobalKey key = GlobalKey();

  Matrix4 matrix = Matrix4.identity();

  bool _isTouched = false;

  Timer? _timer;

  void _setMatrix(Matrix4 matrix4) {
    if (mounted) {
      setState(() {
        matrix = matrix4;
      });
    } else {
      matrix = matrix4;
    }
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
              children: [
                MatrixGestureDetector(
                  onMatrixUpdate:
                      (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
                    setState(() {
                      if (widget.canMove) matrix = m;
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
                    onTap: () => widget.onSetTop(
                        widget.key!, widget.position, widget.widgetType),
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
