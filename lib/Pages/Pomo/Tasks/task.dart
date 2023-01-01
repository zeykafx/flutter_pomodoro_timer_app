import 'package:enum_to_string/enum_to_string.dart';

enum TaskType { done, inProgress, notStarted }

class Task {
  int id;
  String content;
  TaskType taskType;
  int plannedPomos;
  int pomosDone;

  Task({
    required this.id,
    required this.content,
    required this.taskType,
    required this.plannedPomos,
    required this.pomosDone,
  });

  int incrementPomos() {
    pomosDone++;
    return pomosDone;
  }

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
      "taskType": EnumToString.convertToString(taskType),
      "plannedPomos": plannedPomos,
      "pomosDone": pomosDone
    };
  }
}
