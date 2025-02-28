part of 'yolo_process_bloc.dart';

class YoloProcessState extends Equatable {

  final bool yolov10;
  final String imageUrl;
  final bool isLoading;
  CardDataDto cardDataDto;

  YoloProcessState({
    this.yolov10 = false,
    this.imageUrl = '',
    this.isLoading = false, 
    CardDataDto? cardDataDto,
  }) : cardDataDto = cardDataDto ?? CardDataDto.empty;

  YoloProcessState copyWith({
    bool? yolov10,
    String? imageUrl,
    bool? isLoading,
    CardDataDto? cardDataDto, 
  }) {
    return YoloProcessState(
      yolov10: yolov10 ?? this.yolov10,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      cardDataDto: cardDataDto ?? this.cardDataDto,
    );
  }
  
  @override
  List<Object> get props => [yolov10, imageUrl, isLoading, cardDataDto];
}

