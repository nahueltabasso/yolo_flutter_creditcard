import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {
  YoloProcessBloc() : super(YoloProcessState()) {
    on<YoloProcessEvent>((event, emit) {
      on<InitPicker>((event, emit) => initPicker(event, emit));
      on<LoadImage>((event, emit) => loadImage(event, emit));  
    });
  }

  Future<void> initPicker(InitPicker event, Emitter<YoloProcessState> emit) async {
    emit(state.copyWith(
      imageSource: event.source,
    ));
  }

  Future<void> loadImage(LoadImage event, Emitter<YoloProcessState> emit) async {
    final selectedFile = await ImagePicker().pickImage(source: state.imageSource);
    if (selectedFile != null) {
      final image = File(selectedFile.path);
      emit(state.copyWith(image: image, imageUrl: selectedFile.path));
    }
  }
}
