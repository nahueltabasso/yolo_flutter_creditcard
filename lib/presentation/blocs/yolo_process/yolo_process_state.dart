part of 'yolo_process_bloc.dart';

class YoloProcessState extends Equatable {

  final bool yolov10;
  final ImageSource imageSource;
  final String imageUrl;
  final File? image;

  const YoloProcessState({
    this.yolov10 = false,
    this.imageSource = ImageSource.gallery,
    this.imageUrl = '', 
    this.image
  });

  YoloProcessState copyWith({
    bool? yolov10,
    ImageSource? imageSource,
    String? imageUrl,
    File? image,
  }) {
    return YoloProcessState(
      yolov10: yolov10 ?? this.yolov10,
      imageSource: imageSource ?? this.imageSource,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
    );
  }
  
  @override
  List<Object> get props => [];
}

