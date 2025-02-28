import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/home_screen.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/result_screen.dart';
import 'package:flutter_yolo_creditcard/services/api_service.dart';
import 'package:go_router/go_router.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {

  final ApiService _apiService;

  YoloProcessBloc({required ApiService apiService}) : _apiService = apiService, super(YoloProcessState()) {
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
      // print(state.cardDataDto.cardNumber);
      // print(state.cardDataDto.cardholder);
      // print(state.cardDataDto.expiryDate);
      // print(state.cardDataDto.paymentNetwork);
      // print(state.cardDataDto.obs);
      // print(state.cardDataDto.createAt);

      emit(state.copyWith(
        isLoading: false,
        cardDataDto: state.cardDataDto,
      )); 

      print('State despues de la inferencia $state');
      event.context.push(ResultScreen.routeName);
    } else {
      print("Se ejecuta inferencia con YOLOv8 en el dispositivo");
    }
  }
}