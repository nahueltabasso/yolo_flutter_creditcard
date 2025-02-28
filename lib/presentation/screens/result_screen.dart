import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/presentation/blocs/yolo_process/yolo_process_bloc.dart';
import 'package:flutter_yolo_creditcard/presentation/widgets/custom_button.dart';
import 'package:flutter_yolo_creditcard/presentation/widgets/custom_input_field.dart';

class ResultScreen extends StatelessWidget {
  static const String routeName = '/results';

  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Extracted'),
        centerTitle: true,
      ),
      body: _ResultsView(),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    super.key,
  });

  void _resetForm(BuildContext context) {
    context.read<YoloProcessBloc>().add(ResetForm(context));
  }

  @override
  Widget build(BuildContext context) {
    CardDataDto cardDataDto = context.select((YoloProcessBloc bloc) => bloc.state.cardDataDto);
    if (cardDataDto.obs == 'Invalid image') {
      return _InvalidImageMessage(onPressed: () => _resetForm(context));
    }

    return Form(
      child: Column(
        children: [
          const SizedBox(height: 40),

          CustomInputField(
            label: 'Card Number',
            initialValue: cardDataDto.cardNumber,
            keyboardType: TextInputType.number, 
            autocorrect: false,
            prefixIcon: Icons.credit_card,
            onChanged: (value) {},
          ),

          const SizedBox(height: 30),

          CustomInputField(
            label: 'Cardholder',
            initialValue: cardDataDto.cardholder,
            keyboardType: TextInputType.text,
            autocorrect: false,
            prefixIcon: Icons.person_2_outlined,
            onChanged: (value) {},
          ),

          const SizedBox(height: 30),

          CustomInputField(
            label: 'Expiry Date',
            initialValue: cardDataDto.expiryDate,
            keyboardType: TextInputType.datetime,
            autocorrect: false,
            prefixIcon: Icons.calendar_month_outlined,
            onChanged: (value) {},
          ),

          const SizedBox(height: 30),

          CustomInputField(
            label: 'Payment Network',
            initialValue: cardDataDto.paymentNetwork,
            keyboardType: TextInputType.text,
            autocorrect: false,
            prefixIcon: Icons.home_work_outlined,
            onChanged: (value) {},
            enabled: false,
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Text(
              'The inference was made with ${cardDataDto.yoloV10! ? 'YOLOv10' : 'YOLOv8'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),  
            ),
          ),

          const SizedBox(height: 30),

          CustomButton(
            label: 'Reset',
            width: MediaQuery.of(context).size.width * 0.9,
            onPressed: () => _resetForm(context),
          )
        ],
      ),
    );
  }
}

class _InvalidImageMessage extends StatelessWidget {

  final VoidCallback? onPressed;

  const _InvalidImageMessage({
    super.key, 
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Text('Invalid image', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('The image is not valid for processing', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Reset',
            width: MediaQuery.of(context).size.width * 0.9,
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}