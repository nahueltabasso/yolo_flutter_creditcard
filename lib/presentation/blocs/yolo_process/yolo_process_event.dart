part of 'yolo_process_bloc.dart';

class YoloProcessEvent extends Equatable {
  const YoloProcessEvent();

  @override
  List<Object> get props => [];
}

class LoadImage extends YoloProcessEvent {

  final ImageSource source;
  final String image;

  const LoadImage({required this.source, required this.image});

  @override
  List<Object> get props => [image!];
}