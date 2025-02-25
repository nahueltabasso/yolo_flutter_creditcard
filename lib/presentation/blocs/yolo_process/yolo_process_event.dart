part of 'yolo_process_bloc.dart';

class YoloProcessEvent extends Equatable {
  const YoloProcessEvent();

  @override
  List<Object> get props => [];
}


class InitPicker extends YoloProcessEvent {
  
  final ImageSource source;
 
  const InitPicker(this.source);
}

class LoadImage extends YoloProcessEvent {

  final String image;

  const LoadImage({required this.image});

  @override
  List<Object> get props => [image!];
}