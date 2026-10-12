import 'package:flutter_test/flutter_test.dart';
import 'package:don3txt/domain/task_sort_criterion.dart';
import 'package:don3txt/domain/todo_item.dart';

TodoItem _task({
  String description = 'Task',
  String? priority,
  String? due,
  String? threshold,
  DateTime? creationDate,
}) {
  final metadata = <String, String>{};

  if (due != null) metadata['due'] = due;
  if (threshold != null) metadata['t'] = threshold;

  return TodoItem(
    description: description,
    priority: priority,
    creationDate: creationDate,
    metadata: metadata,
  );
}

void main() {
  group('compareTasksBy', () {
    group('priority criterion', () {
      group('ascending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.priority, SortDirection.ascending),
        ]);

        test('task with priority comes before one without', () {
          final withPri = _task(priority: 'A');
          final withoutPri = _task();

          expect(compare(withPri, withoutPri), isNegative);
          expect(compare(withoutPri, withPri), isPositive);
        });

        test('higher priority (A) comes before lower (B)', () {
          final a = _task(priority: 'A');
          final b = _task(priority: 'B');

          expect(compare(a, b), isNegative);
        });

        test('same priority is tie', () {
          final a = _task(priority: 'B');
          final b = _task(priority: 'B');

          expect(compare(a, b), 0);
        });
      });

      group('descending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.priority, SortDirection.descending),
        ]);

        test('task with priority comes before one without (nulls always last)', () {
          final withPri = _task(priority: 'Z');
          final withoutPri = _task();

          expect(compare(withPri, withoutPri), isNegative);
          expect(compare(withoutPri, withPri), isPositive);
        });

        test('lower priority (B) comes before higher (A)', () {
          final a = _task(priority: 'A');
          final b = _task(priority: 'B');

          expect(compare(b, a), isNegative);
          expect(compare(a, b), isPositive);
        });

        test('same priority is tie', () {
          final a = _task(priority: 'B');
          final b = _task(priority: 'B');

          expect(compare(a, b), 0);
        });
      });
    });

    group('due criterion', () {
      group('ascending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.due, SortDirection.ascending),
        ]);

        test('task with due comes before one without (null last)', () {
          final withDue = _task(due: '2026-03-10');
          final withoutDue = _task();

          expect(compare(withDue, withoutDue), isNegative);
          expect(compare(withoutDue, withDue), isPositive);
        });

        test('earlier due comes first', () {
          final earlier = _task(due: '2026-03-01');
          final later = _task(due: '2026-03-10');

          expect(compare(earlier, later), isNegative);
          expect(compare(later, earlier), isPositive);
        });

        test('same due date is tie', () {
          final a = _task(due: '2026-03-10');
          final b = _task(due: '2026-03-10');

          expect(compare(a, b), 0);
        });
      });

      group('descending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.due, SortDirection.descending),
        ]);

        test('later due comes first (późniejsze terminy przed wcześniejszymi)', () {
          final earlier = _task(due: '2026-03-01');
          final later = _task(due: '2026-03-10');

          expect(compare(later, earlier), isNegative);
          expect(compare(earlier, later), isPositive);
        });

        test('tasks without due remain at the end regardless of direction', () {
          final earlier = _task(due: '2026-03-01');
          final later = _task(due: '2026-03-10');
          final withoutDue = _task();

          expect(compare(later, withoutDue), isNegative);
          expect(compare(earlier, withoutDue), isNegative);
          expect(compare(withoutDue, later), isPositive);
          expect(compare(withoutDue, earlier), isPositive);
        });

        test('tasks both without due result in tie', () {
          final withoutDue1 = _task(description: 'Task 1');
          final withoutDue2 = _task(description: 'Task 2');

          expect(compare(withoutDue1, withoutDue2), 0);
        });
      });
    });

    group('threshold criterion', () {
      group('ascending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.threshold, SortDirection.ascending),
        ]);

        test('task with t comes before one without (null last)', () {
          final withT = _task(threshold: '2026-03-10');
          final withoutT = _task();

          expect(compare(withT, withoutT), isNegative);
          expect(compare(withoutT, withT), isPositive);
        });

        test('earlier t comes first', () {
          final earlier = _task(threshold: '2026-03-01');
          final later = _task(threshold: '2026-03-10');

          expect(compare(earlier, later), isNegative);
        });
      });

      group('descending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.threshold, SortDirection.descending),
        ]);

        test('later t comes first, null remains last', () {
          final earlier = _task(threshold: '2026-03-01');
          final later = _task(threshold: '2026-03-10');
          final withoutT = _task();

          expect(compare(later, earlier), isNegative);
          expect(compare(later, withoutT), isNegative);
          expect(compare(withoutT, later), isPositive);
        });
      });
    });

    group('creation criterion', () {
      group('ascending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.creation, SortDirection.ascending),
        ]);

        test('task with creation date comes before one without (null last)', () {
          final withDate = _task(creationDate: DateTime(2026, 3, 1));
          final withoutDate = _task();

          expect(compare(withDate, withoutDate), isNegative);
          expect(compare(withoutDate, withDate), isPositive);
        });

        test('earlier creation comes first', () {
          final earlier = _task(creationDate: DateTime(2026, 3, 1));
          final later = _task(creationDate: DateTime(2026, 3, 10));

          expect(compare(earlier, later), isNegative);
        });
      });

      group('descending', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.creation, SortDirection.descending),
        ]);

        test('later creation comes first, null remains last', () {
          final earlier = _task(creationDate: DateTime(2026, 3, 1));
          final later = _task(creationDate: DateTime(2026, 3, 10));
          final withoutDate = _task();

          expect(compare(later, earlier), isNegative);
          expect(compare(later, withoutDate), isNegative);
          expect(compare(withoutDate, later), isPositive);
        });
      });
    });

    group('chained criteria', () {
      test('default chain: due (desc) -> creation (asc) -> priority (asc)', () {
        final compare = compareTasksBy([
          const TaskSortOrder(TaskSortCriterion.due, SortDirection.descending),
          const TaskSortOrder(TaskSortCriterion.creation, SortDirection.ascending),
          const TaskSortOrder(TaskSortCriterion.priority, SortDirection.ascending),
        ]);

        // Task with later due date comes first
        final tLaterDue = _task(due: '2026-12-31', creationDate: DateTime(2026, 5, 1));
        final tEarlierDue = _task(due: '2026-01-01', creationDate: DateTime(2026, 1, 1));
        expect(compare(tLaterDue, tEarlierDue), isNegative);

        // Tie on due date breaks by creation date ascending (earlier creation first)
        final tTieDueEarlierCreation = _task(
          due: '2026-06-01',
          creationDate: DateTime(2026, 1, 1),
          priority: 'B',
        );
        final tTieDueLaterCreation = _task(
          due: '2026-06-01',
          creationDate: DateTime(2026, 2, 1),
          priority: 'A',
        );
        expect(compare(tTieDueEarlierCreation, tTieDueLaterCreation), isNegative);

        // Tie on due and creation breaks by priority ascending (A before B)
        final tTieAllPriA = _task(
          due: '2026-06-01',
          creationDate: DateTime(2026, 1, 1),
          priority: 'A',
        );
        final tTieAllPriB = _task(
          due: '2026-06-01',
          creationDate: DateTime(2026, 1, 1),
          priority: 'B',
        );
        expect(compare(tTieAllPriA, tTieAllPriB), isNegative);

        // Tasks without due date are always pushed to bottom
        final tNoDue = _task(priority: 'A', creationDate: DateTime(2026, 1, 1));
        expect(compare(tLaterDue, tNoDue), isNegative);
        expect(compare(tEarlierDue, tNoDue), isNegative);
      });

      test('empty chain returns 0 for any pair', () {
        final compare = compareTasksBy([]);

        final a = _task(priority: 'A', due: '2026-01-01');
        final b = _task();

        expect(compare(a, b), 0);
      });

      test('compareTasksByCriteria backward compatibility helper', () {
        final compare = compareTasksByCriteria([
          TaskSortCriterion.priority,
          TaskSortCriterion.due,
        ]);

        final a = _task(priority: 'A', due: '2026-03-10');
        final b = _task(priority: 'B', due: '2026-03-01');

        expect(compare(a, b), isNegative);
      });
    });

    group('TaskSortCriterion.parse', () {
      test('round-trips known names', () {
        for (final c in TaskSortCriterion.values) {
          expect(TaskSortCriterion.parse(c.name), c);
        }
      });

      test('returns null for unknown name', () {
        expect(TaskSortCriterion.parse('nope'), isNull);
        expect(TaskSortCriterion.parse(null), isNull);
      });
    });

    group('TaskSortOrder and SortDirection', () {
      test('round-trips serialization and parsing', () {
        const order1 = TaskSortOrder(TaskSortCriterion.due, SortDirection.descending);
        expect(order1.serialize(), 'due:descending');
        expect(TaskSortOrder.parse('due:descending'), order1);
        expect(TaskSortOrder.parse('due:desc'), order1);

        const order2 = TaskSortOrder(TaskSortCriterion.priority, SortDirection.ascending);
        expect(order2.serialize(), 'priority:ascending');
        expect(TaskSortOrder.parse('priority:ascending'), order2);
        expect(TaskSortOrder.parse('priority:asc'), order2);
      });

      test('parses legacy format without direction as ascending', () {
        expect(
          TaskSortOrder.parse('priority'),
          const TaskSortOrder(TaskSortCriterion.priority, SortDirection.ascending),
        );
        expect(
          TaskSortOrder.parse('due'),
          const TaskSortOrder(TaskSortCriterion.due, SortDirection.ascending),
        );
      });

      test('toggleDirection switches between ascending and descending', () {
        const asc = TaskSortOrder(TaskSortCriterion.due, SortDirection.ascending);
        final desc = asc.toggleDirection();
        expect(desc.direction, SortDirection.descending);
        expect(desc.toggleDirection().direction, SortDirection.ascending);
      });

      test('returns null for invalid inputs', () {
        expect(TaskSortOrder.parse(null), isNull);
        expect(TaskSortOrder.parse(''), isNull);
        expect(TaskSortOrder.parse('unknown:asc'), isNull);
      });
    });
  });
}
