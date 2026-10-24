class MomentPhoto {
  const new({required this.id, this.localPath, this.remoteUrl});

  final String id;
  final String? localPath; // antes de subirla
  final String? remoteUrl; // después de subirla
}
