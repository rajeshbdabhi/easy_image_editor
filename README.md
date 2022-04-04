<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Easy Image Editor
<p align="center">
  <a href="https://pub.dev/packages/easy_image_editor">
    <img src="https://img.shields.io/pub/v/easy_image_editor?color=blue" alt="pub.dev version">
  </a>
  <a href="https://github.com/EdsonBueno/focus_detector/actions">
    <img src="https://github.com/EdsonBueno/focus_detector/workflows/build/badge.svg" alt="GitHub Build Badge">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License Badge">
  </a>
  <a href="https://github.com/EdsonBueno/focus_detector">
    <img src="https://img.shields.io/badge/platform-flutter-ff69b4.svg" alt="Flutter Platform Badge">
  </a>
</p>
`EasyImageEditor` use for add any kind of widget over the background image or color and move that widget, resize, rotate.

<p align="center">
    <img src="https://github.com/rajeshbdabhi/easy_image_editor/blob/master/assets/Record_1.gif" alt="screenshot">
</p>

## Features

1) change editor background color.
2) add any widget as background in editor.
3) add any widget over the editor.
4) move, resize and rotate added widget.
5) update added widget with another widget.
6) allow undo and redo.
7) allow single and multiple selection.
8) allow change border color and remove icon.
9) remove added widget.

## Getting started

First, add `easy_image_editor` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).
then add this line in your file `import 'package:easy_image_editor/easy_image_editor.dart';`

## Usage

```dart
    import 'package:easy_image_editor/easy_image_editor.dart';

    class _MyHomePageState extends State<MyHomePage> {
        late EditorView editorView;

        @override
        void initState() {
            super.initState();
            editorView = EditorView();
            ...
        }
        ...

        @override
        Widget build(BuildContext context) {
            return Scaffold(
                    ...
                    body: editorView,
                    ...
            );
        }
        ...
    }
```
for more detail and usage see /example/lib/main.dart

## Additional information

1) `borderColor` use for set border color of widget default value `Colors.black`.
2) `removeIcon` set remove icon of widget default value `Icon(Icons.cancel)`.
3) `onViewTouch` this event call when widget touch.
4) `onViewTouchOver` this event call when widget touch remove.
5) `addBackgroundColor` set background color of editor.
6) `addBackgroundView` set background color of editor. it will overlap background color.
7) `addView` add any kind of view over the editor.
8) `updateView` update added view in editor.
9) `canEditMultipleView` set edit selection mode multiple or single default value `true`.
10) `hideViewControl` it will hide borders and remove icons of all added widget.
11) `showViewControl` it will show borders and remove icons of all added widget.