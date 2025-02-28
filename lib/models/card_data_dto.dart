import 'dart:convert';

class CardDataDto {
    String paymentNetwork;
    String cardNumber;
    String cardholder;
    String expiryDate;
    DateTime createAt;
    String obs;

    CardDataDto({
        required this.paymentNetwork,
        required this.cardNumber,
        required this.cardholder,
        required this.expiryDate,
        required this.createAt,
        required this.obs,
    });

    factory CardDataDto.fromRawJson(String str) => CardDataDto.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CardDataDto.fromJson(Map<String, dynamic> json) => CardDataDto(
        paymentNetwork: json["payment_network"],
        cardNumber: json["card_number"],
        cardholder: json["cardholder"],
        expiryDate: json["expiry_date"],
        createAt: DateTime.parse(json["create_at"]),
        obs: json["obs"],
    );

    Map<String, dynamic> toJson() => {
        "payment_network": paymentNetwork,
        "card_number": cardNumber,
        "cardholder": cardholder,
        "expiry_date": expiryDate,
        "create_at": createAt.toIso8601String(),
        "obs": obs,
    };

    static final empty = CardDataDto(
      paymentNetwork: '',
      cardNumber: '',
      cardholder: '',
      expiryDate: '',
      createAt: DateTime.now(),
      obs: '',
    );

}
