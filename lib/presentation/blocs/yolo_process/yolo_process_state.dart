part of 'yolo_process_bloc.dart';

class YoloProcessState extends Equatable {

  final bool yolov10;
  final String imageUrl;
  final File? image;

  const YoloProcessState({
    this.yolov10 = false,
    this.imageUrl = '', 
    this.image
  });

  YoloProcessState copyWith({
    bool? yolov10,
    String? imageUrl,
    File? image,
  }) {
    return YoloProcessState(
      yolov10: yolov10 ?? this.yolov10,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
    );
  }
  
  @override
  List<Object> get props => [];
}

