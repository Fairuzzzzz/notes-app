class Note {
  final String id;
  final String title;
  final String content;
  final String workspaceId;
  final DateTime createdAt;

  Note(
      {required this.id,
      required this.title,
      required this.content,
      required this.workspaceId,
      required this.createdAt});
}
