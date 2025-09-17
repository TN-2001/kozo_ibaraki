import 'package:flutter/material.dart';

class PixelCanvasController extends ChangeNotifier {
  PixelCanvasController() {
    _initCanvas();
  }


  // パラメータ
  int _gridWidth = 16;
  int _gridHeight = 16;
  Color _selectedColor = Colors.black;
  late List<Color> _pixelColors;
  final List<List<Color>> _undoStack = [];
  final List<List<Color>> _redoStack = [];
  late List<bool> _pixelPaintableFlags;

  // final TextEditingController widthController = TextEditingController(text: '16');
  // final TextEditingController heightController = TextEditingController(text: '16');


  // ゲッター
  int get gridWidth => _gridWidth;
  int get gridHeight => _gridHeight;
  Color get selectedColor => _selectedColor;
  Color getPixelColor(int index) {
    return _pixelColors[index];
  }
  bool getPixelPaintableFlag(int index) {
    return _pixelPaintableFlags[index];
  }


  // 関数
  void _initCanvas() {
    _pixelColors = List.generate(_gridWidth * _gridHeight, (_) => const Color.fromARGB(0, 255, 255, 255));
    _undoStack.clear();
    _redoStack.clear();
    _pixelPaintableFlags = List.generate(_gridWidth * _gridHeight, (_) => true);
    notifyListeners();
  }

  void saveToUndo() {
    _undoStack.add(List<Color>.from(_pixelColors));
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(List<Color>.from(_pixelColors));
      _pixelColors = _undoStack.removeLast();
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List<Color>.from(_pixelColors));
      _pixelColors = _redoStack.removeLast();
      notifyListeners();
    }
  }

  void symmetrical() {
    saveToUndo();
    for (int y = 0; y < _gridHeight; y++) {
      for (int x = 0; x < _gridWidth / 2; x++) {
        _pixelColors[_gridWidth * y + _gridWidth - x - 1] = _pixelColors[_gridWidth * y + x];
      }
    }
    notifyListeners();
  }

  void clear() {
    saveToUndo();
    for (var i = 0; i < gridWidth * gridHeight; i++) {
      if (_pixelPaintableFlags[i]) {
        _pixelColors[i] = const Color.fromARGB(0, 255, 255, 255);
      }
    }
    notifyListeners();
  }

  // void resizeCanvas() {
  //   final newW = int.tryParse(widthController.text);
  //   final newH = int.tryParse(heightController.text);
  //   if (newW != null && newW > 0 && newH != null && newH > 0) {
  //     _gridWidth = newW;
  //     _gridHeight = newH;
  //     _initCanvas();
  //   }
  // }
  void resizeCanvas(int width, int height) {
    if (width > 0 && height > 0) {
      _gridWidth = width;
      _gridHeight = height;
      _initCanvas();
    }
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  // void paintPixel(Offset localPos, Size size) {
  //   final cellWidth = size.width / _gridWidth;
  //   final cellHeight = size.height / _gridHeight;

  //   final x = (localPos.dx ~/ cellWidth).clamp(0, _gridWidth - 1);
  //   final y = (localPos.dy ~/ cellHeight).clamp(0, _gridHeight - 1);
  //   final index = y * _gridWidth + x;

  //   if (_pixelColors[index] != _selectedColor) {
  //     _pixelColors[index] = _selectedColor;
  //     notifyListeners();
  //   }
  // }
  void paintPixel(int index) {
    if (index < 0 || index >= gridWidth * gridHeight) {
      return;
    }
    if (getPixelPaintableFlag(index) == false) {
      return;
    }

    _pixelColors[index] = _selectedColor;
    notifyListeners();
  }

  void setPixelPaintableFlag(int index, bool value) {
    if (index < 0 || index >= gridWidth * gridHeight) {
      return;
    }

    _pixelPaintableFlags[index] = value;
  }


  @override
  void dispose() {
    // widthController.dispose();
    // heightController.dispose();
    super.dispose();
  }
}
