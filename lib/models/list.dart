class Task {
  int id;
  String title;
  String details;
  bool isCompleted;

  Task(this.id, this.title, this.details, this.isCompleted);

  @override
  String toString() {
    return title;
  }
}
