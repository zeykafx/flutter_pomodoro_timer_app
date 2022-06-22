enum TaskType {
  done,
  inProgress,
  notStarted
}

class Task {
  int id;
  String content;
  TaskType taskType;

  Task({
    required this.id,
    required this.content,
    required this.taskType,
  });

  TaskType changeType(TaskType newType) {
    taskType = newType;
    return taskType;
  }

  String changeContent(String newContent) {
    content = newContent;
    return content;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "content": content,
      "taskType": taskType
    };
  }
}
