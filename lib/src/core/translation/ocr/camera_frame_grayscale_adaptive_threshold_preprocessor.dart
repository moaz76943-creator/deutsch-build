/// Task 1761: Camera frame adaptive thresholding and binarization for OCR
class CameraFrameOcrPreprocessor {
  List<int> binarizeFrame(List<int> grayscalePixels, int width, int height) => grayscalePixels.map((p) => p > 128 ? 255 : 0).toList();
}
