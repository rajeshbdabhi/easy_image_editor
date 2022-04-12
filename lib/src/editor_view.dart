import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'resizable_widget.dart';

class EditorView extends StatefulWidget {
  EditorView({
    key,
    this.onViewTouch,
    this.onViewTouchOver,
    this.onClick,
    this.clickToFocusAndMove = false,
    this.borderColor = Colors.black,
    this.removeIcon = const Icon(
      Icons.cancel,
      size: 20.0,
    ),
  }) : super(key: key);

  final _editorViewState = _EditorViewState();

  @override
  // ignore: no_logic_in_create_state
  _EditorViewState createState() => _editorViewState;

  /// save all edited views and his position and return Uint8List data.
  Future<Uint8List?> saveEditing() => _editorViewState._saveView();

  /// This function user for add view in editor
  void addView(Widget view, {String? widgetType}) =>
      _editorViewState._addView(view, widgetType);

  /// update view of given position.
  void updateView(int position, Widget view) =>
      _editorViewState._updateView(position, view);

  /// hide Border and Remove button from all views
  void hideViewControl() => _editorViewState._disableEditMode();

  /// show Border and Remove button in all views
  void showViewControl() => _editorViewState._enableEditModel();

  /// allow editor to move, zoom and rotate multiple views. if you set true than only one view can move, zoom and rotate default value is true.
  void canEditMultipleView(bool isMultipleSelection) =>
      _editorViewState._setSelectionMode(!isMultipleSelection);

  /// set editor background view it will overlap background color.
  void addBackgroundView(Widget? view) => _editorViewState._addBGView(view);

  /// set editor background color.
  void addBackgroundColor(Color color) => _editorViewState._addBGColor(color);

  /// redo your changes
  void redo() => _editorViewState._redo();

  /// undo your changes
  void undo() => _editorViewState._undo();

  /// this event fire every time you touch view.
  final Function(int, Widget, String?)? onViewTouch;

  /// this event fire every time when user remove touch from view.
  final Function(int, Widget, String?)? onViewTouchOver;

  /// this event fire every time when user click view.
  final Function(int, Widget, String?)? onClick;

  /// set border color of widget
  final Color borderColor;

  /// set remove icon
  final Icon removeIcon;

  final bool clickToFocusAndMove;

  /// move view by provide position and move type like left, right and his his value.
  /// Ex. position = 0, moveType = MoveType.left, value = 10
  void moveView(int position, MoveType moveType, double value) =>
      _editorViewState._moveView(position, moveType, value);

  /// rotate particular view
  void rotateView(int position, double rotateDegree) =>
      _editorViewState._rotateView(position, rotateDegree);

  /// zoom In and Out view
  /// for zoom view value > 1
  /// for zoom out view value < 0 like (0.1)
  void zoomInOutView(int position, double value) =>
      _editorViewState._zoomInOut(position, value);

  /// update matrix of particular view
  void updateMatrix(int position, Matrix4 matrix4) =>
      _editorViewState._updateMatrix(position, matrix4);

  /// flip particular view
  void flipView(int position, bool isHorizontal) =>
      _editorViewState._flipView(position, isHorizontal);
}

class _EditorViewState extends State<EditorView> {
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<ResizableWidget> _widgetList = [];
  final List<ResizableWidget> widgetList = [];

  bool isSingleMove = false;

  Color? _backgroundColor;
  Widget? _backgroundWidget;

  Future<Uint8List?> _saveView() async {
    _disableEditMode();
    return await _screenshotController.capture();
  }

  void _addBGView(Widget? view) {
    if (mounted) {
      setState(() {
        _backgroundWidget = view;
      });
    } else {
      _backgroundWidget = view;
    }
  }

  void _addBGColor(Color color) {
    if (mounted) {
      setState(() {
        _backgroundColor = color;
      });
    } else {
      _backgroundColor = color;
    }
  }

  void _setSelectionMode(bool isSingleSelection) {
    if (mounted) {
      setState(() {
        isSingleMove = isSingleSelection;

        if (isSingleMove) {
          _disableEditMode();
        } else {
          _enableEditModel();
        }
      });
    } else {
      isSingleMove = isSingleSelection;
    }
  }

  void _disableEditMode() {
    if (mounted) {
      setState(() {
        for (var element in _widgetList) {
          element.showRemoveIcon = false;
          element.borderColor = Colors.transparent;
          element.updateView();
        }
      });
    }
    //screenshotController.capture().then((value) => null);
  }

  void _enableEditModel() {
    if (mounted) {
      setState(() {
        for (var element in _widgetList) {
          element.showRemoveIcon = true;
          element.borderColor = widget.borderColor;
          element.updateView();
        }
      });
    }
  }

  void _updateView(int position, Widget view) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);
    setState(() {
      debugPrint("viewUpdated");
      _widgetList[position].resizableWidget = view;
      _widgetList[position].updateView();
    });
  }

  void _addView(Widget view, String? widgetType) {
    if (mounted) {
      setState(() {
        _addViewInList(view, widgetType);
      });
    } else {
      _addViewInList(view, widgetType);
    }
  }

  void _addViewInList(Widget view, String? widgetType, {Matrix4? matrix4}) {
    if (_widgetList.isNotEmpty) {
      final lastViewItem = _widgetList.last;
      lastViewItem.showRemoveIcon = false;
      lastViewItem.borderColor = Colors.transparent;
      lastViewItem.canMove = false;
      lastViewItem.updateView();
    }

    final resizableView = ResizableWidget(
      key: ObjectKey(DateTime.now().toString()),
      position: _widgetList.length,
      canMove: true,
      borderColor: widget.borderColor,
      removeIcon: widget.removeIcon,
      resizableWidget: view,
      widgetType: widgetType,
      matrix4: matrix4,
      onRemoveClick: (key, index) {
        setState(() {
          //_widgetList.removeWhere((element) => element.key == key);
          try {
            final removeView =
                _widgetList.firstWhere((element) => element.key == key);
            removeView.isVisible = false;
            removeView.updateView();
          } catch (_) {}
        });
      },
      onClick: (key, index, widgetType) {
        if (widget.clickToFocusAndMove) {
          setState(() {
            final finalIndex =
                _widgetList.indexWhere((element) => element.key == key);

            final touchView = _widgetList.removeAt(finalIndex);
            touchView.showRemoveIcon = true;
            touchView.canMove = true;
            touchView.borderColor = widget.borderColor;
            touchView.updateView();
            _widgetList.add(touchView);

            if (widget.onClick != null) {
              widget.onClick!(_widgetList.length - 1, touchView.resizableWidget,
                  touchView.widgetType);
            }

            if (isSingleMove) {
              for (var element in _widgetList) {
                if (element != touchView) {
                  element.showRemoveIcon = false;
                  element.borderColor = Colors.transparent;
                  element.canMove = false;
                  element.updateView();
                }
              }
            }
          });
        } else {
          final finalIndex =
              _widgetList.indexWhere((element) => element.key == key);

          final touchView = _widgetList[finalIndex];

          if (widget.onClick != null) {
            widget.onClick!(_widgetList.length - 1, touchView.resizableWidget,
                touchView.widgetType);
          }
        }
      },
      onSetTop: (key, index, widgetType) {
        debugPrint("onTouch");
        if (!widget.clickToFocusAndMove) {
          setState(() {
            final finalIndex =
                _widgetList.indexWhere((element) => element.key == key);

            final touchView = _widgetList.removeAt(finalIndex);
            touchView.showRemoveIcon = true;
            touchView.canMove = true;
            touchView.borderColor = widget.borderColor;
            touchView.updateView();
            _widgetList.add(touchView);

            if (widget.onViewTouch != null) {
              widget.onViewTouch!(_widgetList.length - 1,
                  touchView.resizableWidget, touchView.widgetType);
            }

            if (isSingleMove) {
              for (var element in _widgetList) {
                if (element != touchView) {
                  element.showRemoveIcon = false;
                  element.borderColor = Colors.transparent;
                  element.canMove = false;
                  element.updateView();
                }
              }
            }
          });
        }
      },
      onTouchOver: (key, position, matrix) {
        if (widget.onViewTouchOver != null) {
          final touchView =
              _widgetList.firstWhere((element) => element.key == key);
          widget.onViewTouchOver!(_widgetList.length - 1,
              touchView.resizableWidget, touchView.widgetType);
        }
      },
    );

    _widgetList.add(resizableView);
  }

  void _undo() {
    if (_widgetList.isNotEmpty) {
      try {
        setState(() {
          final lastUnVisibleView =
              _widgetList.lastWhere((element) => element.isVisible);
          lastUnVisibleView.isVisible = false;
          lastUnVisibleView.updateView();
        });
      } catch (_) {}
    }
  }

  void _redo() {
    if (_widgetList.isNotEmpty) {
      try {
        setState(() {
          final lastUnVisibleView =
              _widgetList.firstWhere((element) => !element.isVisible);
          lastUnVisibleView.isVisible = true;
          lastUnVisibleView.updateView();
        });
      } catch (_) {}
    }
  }

  void _flipView(int position, bool isHorizontal) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);

    setState(() {
      final view = _widgetList[position];
      var myTransform = Matrix4Transform.from(view.matrix4!);
      if (isHorizontal) {
        _widgetList[position]
            .updateMatrix(myTransform.flipHorizontally().matrix4);
      } else {
        _widgetList[position]
            .updateMatrix(myTransform.flipVertically().matrix4);
      }
    });
  }

  void _updateMatrix(int position, Matrix4 matrix) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);
    setState(() {
      _widgetList[position].updateMatrix(matrix);
    });
  }

  void _zoomInOut(int position, double value) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);
    setState(() {
      final view = _widgetList[position];
      var myTransform = Matrix4Transform.from(view.matrix4!);
      _widgetList[position].updateMatrix(myTransform.scale(value).matrix4);
    });
  }

  void _rotateView(int position, double rotateDegree) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);
    setState(() {
      final view = _widgetList[position];
      var myTransform = Matrix4Transform.from(view.matrix4!);
      _widgetList[position].updateMatrix(myTransform
          .rotateByCenterDegrees(
              rotateDegree, Size(view.getWidth(), view.getHeight()))
          .matrix4);
    });
  }

  void _moveView(int position, MoveType moveType, double value) {
    assert(position >= 0 &&
        _widgetList.isNotEmpty &&
        _widgetList.length - 1 <= position);

    setState(() {
      final view = _widgetList[position];
      final matrix = view.matrix4!;
      if (moveType == MoveType.right) {
        matrix.setTranslationRaw(view.getX() + value, view.getY(), 0);
      } else if (moveType == MoveType.bottom) {
        matrix.setTranslationRaw(view.getX(), view.getY() + value, 0);
      } else if (moveType == MoveType.top) {
        matrix.setTranslationRaw(view.getX(), view.getY() - value, 0);
      } else if (moveType == MoveType.left) {
        matrix.setTranslationRaw(view.getX() - value, view.getY(), 0);
      }

      _widgetList[position].updateMatrix(matrix);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.clickToFocusAndMove) {
      _setSelectionMode(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: (_backgroundColor != null) ? _backgroundColor : Colors.white,
        child: ClipRect(
          child: Stack(
            children: [
              if (_backgroundWidget != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _backgroundWidget!,
                ),
              ..._widgetList,
            ],
          ),
        ),
      ),
    );
  }
}

enum MoveType {
  left,
  right,
  top,
  bottom,
}
