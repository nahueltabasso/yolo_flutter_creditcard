part of 'yolo_process_bloc.dart';

class YoloProcessEvent extends Equatable {
  const YoloProcessEvent();

  @override
  List<Object> get props => [];
}


class SetCreditCardImage extends YoloProcessEvent {
  final String imageUrl;

  const SetCreditCardImage(this.imageUrl);

  @override
  List<Object> get props => [];
}

class SetYOLOv10Flag extends YoloProcessEvent {
  final bool yolov10;

  const SetYOLOv10Flag(this.yolov10);

  @override
  List<Object> get props => [yolov10];
}

class OnSubmit extends YoloProcessEvent {

  final BuildContext context;

  const OnSubmit(this.context);

  @override
  List<Object> get props => [context];
}
