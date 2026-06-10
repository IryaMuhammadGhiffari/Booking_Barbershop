class PaymentModel {
  final int    id;
  final int    bookingId;
  final String orderId;
  final String? transactionId;
  final double amount;
  final String? paymentMethod;
  final String status;
  final String? snapToken;
  final String? snapUrl;
  final String? paidAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.orderId,
    this.transactionId,
    required this.amount,
    this.paymentMethod,
    required this.status,
    this.snapToken,
    this.snapUrl,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id:            json['id'],
      bookingId:     json['booking_id'],
      orderId:       json['order_id'],
      transactionId: json['transaction_id'],
      amount:        double.parse(json['amount'].toString()),
      paymentMethod: json['payment_method'],
      status:        json['status'],
      snapToken:     json['snap_token'],
      snapUrl:       json['snap_url'],
      paidAt:        json['paid_at'],
    );
  }

  bool get isPaid    => status == 'paid';
  bool get isPending => status == 'pending';
}
