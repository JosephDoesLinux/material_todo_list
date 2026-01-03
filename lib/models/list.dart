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

// this is the base url for our api, so we don't have to type it every time
const String baseUrl = "https://material-todo-api.onrender.com";
