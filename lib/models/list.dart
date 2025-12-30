class Task {
  String title;
  String details;
  bool isCompleted;

  Task(this.title, this.details, this.isCompleted);

  @override
  String toString() {
    return title;
  }
}
