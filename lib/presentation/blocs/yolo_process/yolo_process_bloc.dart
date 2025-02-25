import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'yolo_process_event.dart';
part 'yolo_process_state.dart';

class YoloProcessBloc extends Bloc<YoloProcessEvent, YoloProcessState> {
  YoloProcessBloc() : super(YoloProcessState()) {
    on<YoloProcessEvent>((event, emit) {
      // TODO: implement event handler
    });
  }


  Future<void> loadImage(LoadImage event, Emitter<YoloProcessState> emit) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: event.source);
    if (image != null) {
      emit(state.copyWith(image: File(image.path)));
    }
  }
}
