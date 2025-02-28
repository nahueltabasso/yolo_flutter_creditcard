import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/models/card_data_dto.dart';
import 'package:flutter_yolo_creditcard/presentation/blocs/yolo_process/yolo_process_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    CardDataDto cardDataDto = context.select((YoloProcessBloc bloc) => bloc.state.cardDataDto);
    return Form(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card),
              ),
              autocorrect: false,
              keyboardType: TextInputType.number,
              initialValue: cardDataDto.cardNumber,
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cardholder',
                prefixIcon: Icon(Icons.person_2_outlined),
              ),
              autocorrect: false,
              keyboardType: TextInputType.text,
              initialValue: cardDataDto.cardholder,
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Expiry Date',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              autocorrect: false,
              keyboardType: TextInputType.datetime,
              initialValue: cardDataDto.expiryDate,
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Payment Network',
                prefixIcon: Icon(Icons.home_work_outlined),
              ),
              keyboardType: TextInputType.datetime,
              initialValue: cardDataDto.paymentNetwork,
              enabled: false,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Text(
              'The inference was made with ${cardDataDto.yoloV10! ? 'YOLOv10' : 'YOLOv8'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),  
            ),
          )
        ],
      ),
    );
  }
}