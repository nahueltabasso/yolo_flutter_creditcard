import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/home_screen.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/result_screen.dart';
import 'package:flutter_yolo_creditcard/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {

  final ApiService _apiService;
  FlutterVision? vision;

  YoloProcessBloc({this.vision, required ApiService apiService}) : _apiService = apiService, super(YoloProcessState()) {
    on<SetCreditCardImage>((event, emit) => _setCreditCardImage(event, emit));
    on<OnSubmit>((event, emit) => onSubmit(event, emit));
    on<SetYOLOv10Flag>((event, emit) => _setYOLOv10Flag(event, emit));
    on<ResetForm>((event, emit) => _resetForm(event, emit));
  }

  void _setCreditCardImage(SetCreditCardImage event, Emitter<YoloProcessState> emit) {
    final creditCardImage = event.imageUrl;
    print('Entra a setCreditCardImage');
    print('SetCreditCardImage - $creditCardImage');
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
    print('File - $file');

    if (state.yolov10) {
      print("Se ejecuta inferencia con YOLOv10 via API Rest");
      state.cardDataDto = (await _apiService.extractCreditCardDataWithYOLOv10(file))!;
      state.cardDataDto.yoloV10 = true;
      emit(state.copyWith(
        isLoading: false,
        cardDataDto: state.cardDataDto,
      )); 

      print('State despues de la inferencia $state');
      event.context.push(ResultScreen.routeName);
    } else {

      print("Se ejecuta inferencia con YOLOv8 en el dispositivo");
      print("Flutter vision $vision");
      if (vision == null) {
        await _initYOLOModel();
      }
      print("Flutter vision iniciado $vision");
      final Size size = MediaQuery.of(event.context).size;
      File? creditCard = await _getCreditCardFromImage(file, size);
      print("Size - ${size.height} - ${size.width}");
      if (creditCard == null) {
        emit(state.copyWith(
          isLoading: false,
        ));
        return;
      }
      emit(state.copyWith(
        isLoading: false,
        imageUrl: creditCard.path,
      ));
    }
  }

  Future<void> _initYOLOModel() async {
    if (vision == null) {
      vision = FlutterVision();
      await vision!.loadYoloModel(
        labels: 'assets/yolov8n_CardDetector_labels.txt',
        modelPath: 'assets/yolov8n_CardDetector_float32.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 2,
        useGpu: true);
    }
  }

  Future<File?> _getCreditCardFromImage(File file, Size size) async {
    // Read bytes from image
    final Uint8List imageBytes = await file.readAsBytes();
    final img.Image image = img.decodeImage(imageBytes)!;

    if (image == null) {
      print("Error to decode the image");
      return null;
    }
    try {
      final imageHeight = image.height;
      final imageWidth = image.width;
      print("Antes de inferencia ancho=$imageWidth alto=$imageHeight");

      final results = await vision!.yoloOnImage(
        bytesList: imageBytes, 
        imageHeight: imageHeight, 
        imageWidth: imageWidth);

        if (results.length > 1 || results.isEmpty) {
          print("Invalid image");
          return null;
        }

        // Only 1 credit card detected
        double factorX = size.width / imageWidth;
        double factorY = size.height / imageHeight;
        print("Results - ${results[0]['box']} - tag - ${results[0]['tag']}");
        final box = results[0]['box'];
        int left = (box[0] as double).toInt();
        int top = (box[1] as double).toInt();
        int width = ((box[2] - box[0]) as double).toInt();
        int height = ((box[3] - box[1]) as double).toInt();
        print("left=$left top=$top width=$width height=$height");
        img.Image creditCard = img.copyCrop(image, x: left, y: top, width: width, height: height);

        final tempDir = await getTemporaryDirectory();
        final creditCardPath = '${tempDir.path}/credit_card.jpg';
        File creditCardFile = File(creditCardPath);
        await creditCardFile.writeAsBytes(img.encodeJpg(creditCard)); 
        return creditCardFile;
    } catch (e) {
      print('ERROR: $e');
    }
  }
}