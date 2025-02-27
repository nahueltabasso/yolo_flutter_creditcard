import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {

  final ApiService _apiService;

  YoloProcessBloc({required ApiService apiService}) : _apiService = apiService, super(YoloProcessState()) {
    on<SetCreditCardImage>((event, emit) => _setCreditCardImage(event, emit));
    on<OnSubmit>((event, emit) => onSubmit(event, emit));
    on<SetYOLOv10Flag>((event, emit) => _setYOLOv10Flag(event, emit));
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

  Future<void> onSubmit(OnSubmit event, Emitter<YoloProcessState> emit) async {
    emit(state.copyWith(
      imageUrl: state.imageUrl,
      yolov10: state.yolov10
    ));

    print('Submit state - $state');

    final file = File(state.imageUrl);
    print('File - $file');

    if (state.yolov10) {
      print("Se ejecuta inferencia con YOLOv10 via API Rest");
      CardDataDto? cardDataDto = await _apiService.extractCreditCardData(file);
    } else {
      print("Se ejecuta inferencia con YOLOv8 en el dispositivo");
    }
  }
}
