import 'dart:convert';

class CardDataDto {
  String paymentNetwork;
  String cardNumber;
  String cardholder;
  String expiryDate;
  DateTime createAt;
  String obs;
  bool? yoloV10;

  CardDataDto({
    required this.paymentNetwork,
    required this.cardNumber,
    required this.cardholder,
    required this.expiryDate,
    required this.createAt,
    required this.obs,
    this.yoloV10 = false,
  });

  factory CardDataDto.fromRawJson(String str) => CardDataDto.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CardDataDto.fromJson(Map<String, dynamic> json) => CardDataDto(
        paymentNetwork: json["payment_network"] ?? '',
        cardNumber: json["card_number"] ?? '',
        cardholder: json["cardholder"] ?? '',
        expiryDate: json["expiry_date"] ?? '',
        createAt: json["create_at"] != null ? DateTime.parse(json["create_at"]) : DateTime.now(),
        obs: json["obs"] ?? '',
        yoloV10: json["yoloV10"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "payment_network": paymentNetwork,
        "card_number": cardNumber,
        "cardholder": cardholder,
        "expiry_date": expiryDate,
        "create_at": createAt.toIso8601String(),
        "obs": obs,
        "yoloV10": yoloV10,
      };

  static final empty = CardDataDto(
    paymentNetwork: '',
    cardNumber: '',
    cardholder: '',
    expiryDate: '',
    createAt: DateTime.now(),
    obs: '',
    yoloV10: false
  );
}