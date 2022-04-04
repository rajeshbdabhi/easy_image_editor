import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'resizable_widget.dart';

class EditorView extends StatefulWidget {
  EditorView({
    key,
    this.onViewTouch,
    this.onViewTouchOver,
    this.borderColor = Colors.black,
    this.removeIcon = const Icon(
      Icons.cancel,
      size: 20.0,
    ),
  }) : super(key: key);

  final _editorViewState = _EditorViewState();

  @override
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

  /// set border color of widget
  final Color borderColor;

  /// set remove icon
  final Icon removeIcon;
}

class _EditorViewState extends State<EditorView> {
  ScreenshotController _screenshotController = ScreenshotController();

  final List<RedoUndoModel> _widgetListRedoUndo = [];
  final List<ResizableWidget> _widgetList = [];

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
      onSetTop: (key, index, widgetType) {
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

          /*final finalIndexRedoUndo = _widgetListRedoUndo
              .indexWhere((element) => element.widget.key == key);

          final touchViewRedoUndo =
              _widgetListRedoUndo.removeAt(finalIndexRedoUndo);
          _widgetListRedoUndo.add(touchViewRedoUndo);*/

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
      },
      onTouchOver: (key, position, matrix) {
        final finalIndex = _widgetListRedoUndo
            .indexWhere((element) => element.widget.key == key);

        _widgetListRedoUndo[finalIndex].matrix = matrix;

        if (widget.onViewTouchOver != null) {
          final touchView =
              _widgetList.firstWhere((element) => element.key == key);
          widget.onViewTouchOver!(_widgetList.length - 1,
              touchView.resizableWidget, touchView.widgetType);
        }
      },
    );
    /*if (matrix4 != null) {
      resizableView.updateMatrix(matrix4);
    } else {
      _widgetListRedoUndo
          .add(RedoUndoModel(widget: resizableView, matrix: matrix4));
    }*/
    _widgetListRedoUndo
        .add(RedoUndoModel(widget: resizableView, matrix: matrix4));

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

class RedoUndoModel {
  ResizableWidget widget;
  Matrix4? matrix;

  RedoUndoModel({required this.widget, required this.matrix});
}
