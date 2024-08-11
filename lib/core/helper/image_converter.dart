import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageConverter {
  ImageConverter._();

  static Future<String> imageToBase64(String img) async {
    File imageFile = File(img);
    Uint8List bytes = await imageFile.readAsBytes();
    String cashBase64String = base64.encode(bytes);
    return cashBase64String;
  }


  static Future<List<String>> imageListToBase64String(
      List<String> visaImgs) async {
    List<String> visaBase64String = [];
    for (var img in visaImgs) {
      File imageFile = File(img);
      Uint8List bytes = await imageFile.readAsBytes();
      visaBase64String.add(base64.encode(bytes));
    }
    return visaBase64String;
  }
}
