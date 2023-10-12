class Message {
  final String text;
  final DateTime date;
  final bool isSentByUser;
  final List<int>? image;
  final String? link;

  const Message({
    required this.text,
    required this.date,
    required this.isSentByUser,
    this.image,
    this.link,
  });
}
