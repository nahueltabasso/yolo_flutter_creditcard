import 'dart:io';

class CardElementsDto {

  File? cardNumberFile;
  File? cardholderFile;
  File? expiryDateFile;
  File? paymentNetworkFile;

  CardElementsDto({
    this.cardNumberFile,
    this.cardholderFile,
    this.expiryDateFile,
    this.paymentNetworkFile,
  });

}