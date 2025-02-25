import 'dart:io';

import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {

  static const String routeName = '/';

  String? image;

  HomeScreen({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return _HomeView(image: image, size: size);
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    super.key,
    required this.image,
    required this.size,
  });

  final String? image;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Validator'),
        centerTitle: true,
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null) 
              Image.file(
                File(image!),
                width: size.width,
                height: 400,
                fit: BoxFit.cover,
              ),
    
            if (image == null) const _InitLegend(),  
    
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CheckboxListTile(
                title: Text("Probar con YOLO_V10 via API Rest"),
                value: false,
                onChanged: (newValue) {
                  print(newValue);
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
              ),
            ),
    
            const SizedBox(height: 20),
    
            SizedBox(
              width: size.width * 0.9,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Abrir Camara', style: const TextStyle(color: Colors.white))
              ),
            ),
    
            const SizedBox(height: 15),
    
            SizedBox(
              width: size.width * 0.9,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Abrir Galeria', style: const TextStyle(color: Colors.white))
              ),
            ),
    
            const SizedBox(height: 15),
    
            SizedBox(
              width: size.width * 0.9,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Procesar', style: const TextStyle(color: Colors.white))
              ),
            ),
    
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
            child: Text("Primero seleccionar una imagen", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
