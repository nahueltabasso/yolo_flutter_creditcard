part of 'yolo_process_bloc.dart';

class YoloProcessState extends Equatable {

  final bool yolov10;
  final String imageUrl;

  const YoloProcessState({
    this.yolov10 = false,
    this.imageUrl = '', 
  });

  YoloProcessState copyWith({
    bool? yolov10,
    ImageSource? imageSource,
    String? imageUrl,
    File? image,
  }) {
    return YoloProcessState(
      yolov10: yolov10 ?? this.yolov10,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  @override
  List<Object> get props => [yolov10, imageUrl];
}

