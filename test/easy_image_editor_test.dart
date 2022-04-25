import 'package:test/test.dart';

import 'package:easy_image_editor/easy_image_editor.dart';

void main() {
  test('should editor save image', () {
    EditorView(
      onInitialize: (controller) {
        expect("controller.saveEditing()", null);
      },
    );
  });
}
