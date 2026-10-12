import 'package:don3txt/domain/todo_item.dart';

enum TaskSortCriterion {
  priority,
  due,
  threshold,
  creation;

  static TaskSortCriterion? parse(String? name) {
    if (name == null) return null;

    for (final c in values) {
      if (c.name == name) return c;
    }

    return null;
  }
}

enum SortDirection {
  ascending,
  descending;

  static SortDirection parse(String? name) {
    if (name == 'desc' || name == 'descending') {
      return SortDirection.descending;
    }
    return SortDirection.ascending;
  }
}

class TaskSortOrder {
  final TaskSortCriterion criterion;
  final SortDirection direction;

  const TaskSortOrder(
    this.criterion, [
    this.direction = SortDirection.ascending,
  ]);

  TaskSortOrder copyWith({
    TaskSortCriterion? criterion,
    SortDirection? direction,
  }) {
    return TaskSortOrder(
      criterion ?? this.criterion,
      direction ?? this.direction,
    );
  }

  TaskSortOrder toggleDirection() {
    return TaskSortOrder(
      criterion,
      direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending,
    );
  }

  String serialize() => '${criterion.name}:${direction.name}';

  static TaskSortOrder? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    final criterion = TaskSortCriterion.parse(parts[0]);
    if (criterion == null) return null;

    final direction = parts.length > 1
        ? SortDirection.parse(parts[1])
        : SortDirection.ascending;

    return TaskSortOrder(criterion, direction);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSortOrder &&
          criterion == other.criterion &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(criterion, direction);

  @override
  String toString() => serialize();
}

typedef TaskComparator = int Function(TodoItem a, TodoItem b);

TaskComparator compareTasksBy(List<TaskSortOrder> chain) {
  return (a, b) {
    for (final order in chain) {
      final result = _compareBy(order, a, b);
      if (result != 0) return result;
    }

    return 0;
  };
}

TaskComparator compareTasksByCriteria(List<TaskSortCriterion> criteria) {
  return compareTasksBy(
    criteria.map((c) => TaskSortOrder(c, SortDirection.ascending)).toList(),
  );
}

int _compareBy(TaskSortOrder order, TodoItem a, TodoItem b) {
  switch (order.criterion) {
    case TaskSortCriterion.priority:
      return _comparePriority(a.priority, b.priority,
          direction: order.direction);
    case TaskSortCriterion.due:
      return _compareNullableString(a.metadata['due'], b.metadata['due'],
          direction: order.direction);
    case TaskSortCriterion.threshold:
      return _compareNullableString(a.metadata['t'], b.metadata['t'],
          direction: order.direction);
    case TaskSortCriterion.creation:
      return _compareNullableDate(a.creationDate, b.creationDate,
          direction: order.direction);
  }
}

int _comparePriority(
  String? a,
  String? b, {
  required SortDirection direction,
}) {
  if (a == b) return 0;
  if (a == null) return 1;
  if (b == null) return -1;

  return direction == SortDirection.ascending
      ? a.compareTo(b)
      : b.compareTo(a);
}

int _compareNullableString(
  String? a,
  String? b, {
  required SortDirection direction,
}) {
  if (a == b) return 0;
  if (a == null) return 1;
  if (b == null) return -1;

  return direction == SortDirection.ascending
      ? a.compareTo(b)
      : b.compareTo(a);
}

int _compareNullableDate(
  DateTime? a,
  DateTime? b, {
  required SortDirection direction,
}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;

  return direction == SortDirection.ascending
      ? a.compareTo(b)
      : b.compareTo(a);
}
