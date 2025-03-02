import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/models/card_elements_dto.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/home_screen.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/result_screen.dart';
import 'package:flutter_yolo_creditcard/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {

  static const int CARD_DETECTOR = 1;
  static const int CARD_ELEMENTS_DETECTOR = 2;

  final ApiService _apiService;
  FlutterVision? cardDetectorVision;
  FlutterVision? cardElementsDetectorVision;

  YoloProcessBloc({this.cardDetectorVision,
                  this.cardElementsDetectorVision, 
                  required ApiService apiService}) : _apiService = apiService, super(YoloProcessState()) {
    on<SetCreditCardImage>((event, emit) => _setCreditCardImage(event, emit));
    on<OnSubmit>((event, emit) => onSubmit(event, emit));
    on<SetYOLOv10Flag>((event, emit) => _setYOLOv10Flag(event, emit));
    on<ResetForm>((event, emit) => _resetForm(event, emit));
  }

  void _setCreditCardImage(SetCreditCardImage event, Emitter<YoloProcessState> emit) {
    final creditCardImage = event.imageUrl;
    print('Enter to setCreditCardImage');
    emit(state.copyWith(imageUrl: creditCardImage));
  }

  void _setYOLOv10Flag(SetYOLOv10Flag event, Emitter<YoloProcessState> emit) {
    emit(state.copyWith(yolov10: event.yolov10));
  }

  void _resetForm(ResetForm event, Emitter<YoloProcessState> emit) {
    event.context.go(HomeScreen.routeName);
    emit(state.copyWith(
      imageUrl: '',
      yolov10: false,
      cardDataDto: CardDataDto.empty,
      isLoading: false
    ));
  }

  Future<void> onSubmit(OnSubmit event, Emitter<YoloProcessState> emit) async {
    emit(state.copyWith(
      imageUrl: state.imageUrl,
      yolov10: state.yolov10,
      isLoading: true,
    ));
    print('Submit state - $state');

    final file = File(state.imageUrl);
    if (state.yolov10) {
      print("Execute YOLOv10 inference through API Rest");
      state.cardDataDto = (await _apiService.extractCreditCardDataWithYOLOv10(file))!;
      state.cardDataDto.yoloV10 = true;
      emit(state.copyWith(
        isLoading: false,
        cardDataDto: state.cardDataDto,
      )); 
      event.context.push(ResultScreen.routeName);
    } 

    if (!state.yolov10) {
      print("Execute YOLOv8 inference in mobile");
      if (cardDetectorVision == null) {
        await _initYOLOModel(CARD_DETECTOR);
      }

      // Detect the card on image
      File? creditCard = await _getCreditCardFromImage(file);
      if (creditCard == null) {
        state.cardDataDto.obs = "Invalid image";
        emit(state.copyWith(
          isLoading: false,
        ));
        event.context.push(ResultScreen.routeName);
        return;
      }

      // Now extract the elements of a card
      if (cardElementsDetectorVision == null) {
        await _initYOLOModel(CARD_ELEMENTS_DETECTOR);
      }
      CardElementsDto? cardElementsDto = await _getCardElements(creditCard);

      cardDetectorVision = null;
      cardElementsDetectorVision = null;
      
      // Extract card data from card elements
      CardDataDto? cardDataDto = await _extractDataFromCardElements(cardElementsDto!);

      // Classify the payment network
      _getPaymentNetwork(cardElementsDto.paymentNetworkFile, cardDataDto!);


      state.cardDataDto = cardDataDto;
      emit(state.copyWith(
        isLoading: false,
        cardDataDto: state.cardDataDto,
      ));
      event.context.push(ResultScreen.routeName);
    }
  }

  Future<void> _initYOLOModel(int modelNumber) async {
    if (modelNumber == 1) {
      cardDetectorVision = FlutterVision();
      await cardDetectorVision!.loadYoloModel(
        labels: 'assets/yolov8n_CardDetector_labels.txt',
        modelPath: 'assets/yolov8n_CardDetector_float32.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 2,
        useGpu: true);
    }

    if (modelNumber == 2) {
      cardElementsDetectorVision = FlutterVision();
      await cardElementsDetectorVision!.loadYoloModel(
        labels: 'assets/yolov8n_CardElementsDetector_labels.txt',
        modelPath: 'assets/yolov8n_CardElementsDetector_float32.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 2,
        useGpu: true);
    }
  }

  Future<File?> _getCreditCardFromImage(File file) async {
    // Read bytes from image
    final Uint8List imageBytes = await file.readAsBytes();
    final img.Image image = img.decodeImage(imageBytes)!;

    // await _initTesseractOCR();
    // await _ocrTesseract(imageBytes);

    if (image == null) {
      print("Error to decode the image");
      return null;
    }
    try {
      final results = await cardDetectorVision!.yoloOnImage(
        bytesList: imageBytes, 
        imageHeight: image.height, 
        imageWidth: image.width);

      print("Results - $results ---- ${results.length}");
      if (results.length > 1 || results.isEmpty) {
        print("Invalid image");
        return null;
      }

      // Only 1 credit card detected
      print("Results - ${results[0]['box']} - tag - ${results[0]['tag']}");
      final box = results[0]['box'];
      final creditCardImg = _cropImage(image, box);
      print("Credit card image - ${creditCardImg.width} - ${creditCardImg.height}");
      File creditCardFile = await _saveTmpImage(creditCardImg, 'credit_card.jpg');
      return creditCardFile;
    } catch (e) {
      print('ERROR: $e');
      return null;
    }
  }

  Future<CardElementsDto?> _getCardElements(File file) async {
    // Read bytes from image
    final Uint8List imageBytes = await file.readAsBytes();
    final img.Image image = img.decodeImage(imageBytes)!;
    if (image == null) {
      print("Error to decode the image");
      return null;
    }

    CardElementsDto cardElementsDto = CardElementsDto();
    try {
      final results = await cardDetectorVision!.yoloOnImage(
        bytesList: imageBytes, 
        imageHeight: image.height, 
        imageWidth: image.width);
      
      for (var result in results) {
        print("Results - ${result['box']} - tag - ${result['tag']}");
        final box = result['box'];
        if (result['tag'] == 'card_number' && cardElementsDto.cardNumberFile == null) {
          final cardNumber = _cropImage(image, box);    
          File cardNumberFile = await _saveTmpImage(cardNumber, 'card_number.jpg');
          cardElementsDto.cardNumberFile = cardNumberFile;
        } 

        if (result['tag'] == 'cardholder' && cardElementsDto.cardholderFile == null) {
          final cardholder = _cropImage(image, box);    
          File cardholderFile = await _saveTmpImage(cardholder, 'cardholder.jpg');
          cardElementsDto.cardholderFile = cardholderFile;
        }

        if (result['tag'] == 'expiry_date' && cardElementsDto.expiryDateFile == null) {
          final expiryDate = _cropImage(image, box);    
          File expiryDateFile = await _saveTmpImage(expiryDate, 'expiry_date.jpg');
          cardElementsDto.expiryDateFile = expiryDateFile;
        }

        if (result['tag'] == 'payment_network' && cardElementsDto.paymentNetworkFile == null) { 
          final paymentNetwork = _cropImage(image, box);    
          File paymentNetworkFile = await _saveTmpImage(paymentNetwork, 'payment_network.jpg');
          cardElementsDto.paymentNetworkFile = paymentNetworkFile;
        }
      }

      print("Card Elements");
      print("1 - ${cardElementsDto.cardNumberFile}");
      print("2 - ${cardElementsDto.cardholderFile}");
      print("3 - ${cardElementsDto.expiryDateFile}");
      return cardElementsDto;
    } catch (e) {
      print('ERROR: $e');
      return null;
    }
  }

  img.Image _cropImage(img.Image image, List<dynamic> box) {
    int left = box[0].toInt();
    int top = box[1].toInt();
    int right = box[2].toInt();
    int bottom = box[3].toInt();
    int width = right - left;
    int height = bottom - top;

    img.Image croppedImage = img.copyCrop(image, x: left, y: top, width: width, height: height);
    return croppedImage;
  }

  Future<File> _saveTmpImage(img.Image image, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final path = join(tempDir.path, filename);
    File file = File(path);
    await file.writeAsBytes(img.encodeJpg(image));
    return file;
  }

  Future<CardDataDto?> _extractDataFromCardElements(CardElementsDto cardElementsDto) async {
    CardDataDto cardDataDto = CardDataDto.empty;
    try {
      if (cardElementsDto.cardNumberFile != null) {
        File file = await preprocessImage(cardElementsDto.cardNumberFile!, "cardNumber.jpg");
        String? cardNumber = await _extractTextFromImage(file);
        cardDataDto.cardNumber = cardNumber ?? "";
      }

      if (cardElementsDto.cardholderFile != null) {
        File file = await preprocessImage(cardElementsDto.cardholderFile!, "cardholder.jpg");
        String? cardholder = await _extractTextFromImage(file);
        cardDataDto.cardholder = cardholder ?? "";
        cardDataDto.cardholder = cardDataDto.cardholder.toUpperCase();
      }

      if (cardElementsDto.expiryDateFile != null) {
        File file = await preprocessImage(cardElementsDto.expiryDateFile!, "expiryDate.jpg");
        String? expiryDate = await _extractTextFromImage(file);
        cardDataDto.expiryDate = expiryDate ?? "";  
      } 
      return cardDataDto;
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  void _getPaymentNetwork(File? file, CardDataDto cardDataDto) {
    // TODO: resolve the payment network
    cardDataDto.paymentNetwork = "------";
  }

  InputImage fileToInputImage(File file) {
    InputImage inputImage = InputImage.fromFile(file);
    return inputImage;
  }

  Future<String?> _extractTextFromImage(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    InputImage inputImage = fileToInputImage(file);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    print("OCR ---- ${recognizedText.text}");
    textRecognizer.close();
    return recognizedText.text;
  }

  Future<File> preprocessImage(File file, String filename, {bool save = false}) async {
    Uint8List imageBytes = await file.readAsBytes();

    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception("Imagen no válida");
    }

    img.Image grayImage = img.grayscale(image);

    double contrast = 1.5;
    img.Image contrastImage = adjustContrast(grayImage, contrast);

    File fileTmp = await _saveTmpImage(
      img.decodeImage(Uint8List.fromList(img.encodeJpg(contrastImage)))!,
      filename);

    return fileTmp;
  }

  img.Image adjustContrast(img.Image image, double factor) {
    int width = image.width;
    int height = image.height;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        num gray = img.getLuminance(pixel); 
        int newGray = ((gray - 128) * factor + 128).clamp(0, 255).toInt();
        
        image.setPixel(x, y, img.ColorInt8.rgb(newGray, newGray, newGray));
      }
    }
    return image;
  }


}