import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/presentation/blocs/yolo_process/yolo_process_bloc.dart';
import 'package:flutter_yolo_creditcard/presentation/widgets/custom_button.dart';
import 'package:flutter_yolo_creditcard/presentation/widgets/custom_loading.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/';

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Extractor'),
        centerTitle: true,
      ),
      // body: BlocProvider(
      //   create: (context) => YoloProcessBloc(
      //     apiService: context.read<ApiService>()
      //   ),
      //   child: _HomeView(size: size),
      body: _HomeView(size: size,
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    super.key,
    required this.size,
  });

  final Size size;

  Future<void> _initPicker(BuildContext context, ImageSource source) async {
    final selectedFile = await ImagePicker().pickImage(source: source);
    if (selectedFile != null) {
      final image = File(selectedFile.path);
      context.read<YoloProcessBloc>().add(SetCreditCardImage(selectedFile.path));
    }
  }


  @override
  Widget build(BuildContext context) {
    final imageUrl = context.select((YoloProcessBloc bloc) => bloc.state.imageUrl);
    final image = imageUrl.isNotEmpty ? File(imageUrl) : null;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.file(
                File(image.path),
                // width: size.width,
                height: 400,
                fit: BoxFit.cover,
              ),
            if (image == null) const _InitLegend(),

            if (context.select((YoloProcessBloc bloc) => bloc.state.isLoading))
              CustomLoading(),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CheckboxListTile(
                title: Text("Testing with YOLOv10 via Rest API"),
                value: context.select((YoloProcessBloc bloc) => bloc.state.yolov10),
                onChanged: (value) => context.read<YoloProcessBloc>().add(SetYOLOv10Flag(value!)),
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
            ),
            
            const SizedBox(height: 20),
            
            CustomButton(
              width: size.width * 0.9,
              label: 'Open Camera',
              onPressed: () => _initPicker(context, ImageSource.camera),
            ),
            
            const SizedBox(height: 15),
            
            CustomButton(
              width: size.width * 0.9,
              label: 'Open Gallery',
              onPressed: () => _initPicker(context, ImageSource.gallery),
            ),

            const SizedBox(height: 15),
            
            CustomButton(
              width: size.width * 0.9,
              label: 'Process',
              onPressed: context.select((YoloProcessBloc bloc) => bloc.state.imageUrl).isEmpty
                      ? null
                      : () => context.read<YoloProcessBloc>().add(OnSubmit(context)),
            )
          ],
        ),
      ),
    );
  }
}

class _InitLegend extends StatelessWidget {
  const _InitLegend({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 100,
          backgroundColor: Colors.green,
          child: Icon(Icons.credit_card_sharp, size: 100, color: Colors.white),
        ),
        Container(
          width: double.infinity,
          height: 150,
          child: const Center(
            child: Text("First select an image",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
