class Channel {
  final String name;
  final String url;
  final String? image;
  final String? key;
  final bool isDash;

  const Channel({required this.name, required this.url, this.image, this.key, this.isDash = false});
}
