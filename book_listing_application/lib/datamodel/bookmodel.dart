class Result {
  final String next;
  final List<Book> book;

  Result({required this.next, required this.book});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        next: json['next'] ?? "",
        book: json["results"] =
            List<Book>.from(json["results"].map((x) => Book.fromJson(x))));
  }
}

class Book {
  final String title;
  final int id;
  final int downloadCount;

  Book({required this.title, required this.id, required this.downloadCount});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      id: json['id'],
      downloadCount: json['download_count'],
    );
  }
}
