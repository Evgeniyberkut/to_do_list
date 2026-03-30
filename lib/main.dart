import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// корнвой виджет
// StatelessWidget — виджет без внутреннего состояния.
// MyApp просто задаёт название и тему приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой планировщик',
      debugShowCheckedModeBanner: false, // убираем надпись DEBUG в углу
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // стартовый экран — "Сегодня"
    );
  }
}

// ─────────────────────────────────────────────
// меин эеран сегодня
// StatefulWidget — виджет с внутренним состоянием
// используется тк  список задач меняется
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// класс где хранятся данные 
// Всё с _ это приватное
class _HomeScreenState extends State<HomeScreen> {
  // список задач на сегодня
  final List<String> _tasks = [];

  // список выполненных задач (кнопка да)
  final List<String> _completedTasks = [];

  // Список архивных задач (кнопка удалить)
  final List<String> _archivedTasks = [];

  //  диалоговое окно с полем для ввода текста
  void _showAddTaskDialog() {
    // TextEditingController управляет текстовым полем:
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новая задача'),
          content: TextField(
            controller: controller,
            autofocus: true, // нагуглил курсор сразу в поле
            decoration: const InputDecoration(
              hintText: 'Введите текст задачи...',
            ),
          ),
          actions: [
            // кноака отмена -закрывает диалог
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            // кнопка добавить сохраняет задачу и закрывает диалог
            TextButton(
              onPressed: () {
                final text = controller.text.trim(); // trim() убирает лишние пробелы
                if (text.isNotEmpty) {
                  // setState() данные изменились нужно чтобы перерисовался экран
                  setState(() {
                    _tasks.add(text);
                  });
                }
                Navigator.pop(context); // закрываем диалог
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // метод нажатия на задачу
  // показывает диалог  "Выполнено?"
  void _showTaskDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выполнено?'),
          content: Text(_tasks[index]), // показываем текст задачи
          actions: [
            // удалить — задача в Архив
            TextButton(
              onPressed: () {
                setState(() {
                  _archivedTasks.add(_tasks[index]); // добавляем в архив
                  _tasks.removeAt(index);             // удаляем из главного списка
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
            // отмена закрываем диалог
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            // да  уходит в выполненные
            TextButton(
              onPressed: () {
                setState(() {
                  _completedTasks.add(_tasks[index]); // добавляем в выполненные
                  _tasks.removeAt(index);              // удаляем из главного списка
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
  }

  // метод восстановить задачу из архива на главный экран 
  // Вызывается из ArchiveScreen через callback
  void _restoreFromArchive(String task) {
    setState(() {
      _archivedTasks.remove(task);
      _tasks.add(task);
    });
  }

  //  build() метод flutter при перерисовке ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar — верхняя полоса с названием экрана
      appBar: AppBar(
        title: const Text('Сегодня'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // содержимое экрана
      body: _tasks.isEmpty
          // Если пуст список  подсказку по центру
          ? const Center(
              child: Text(
                'Нет задач. Нажми + чтобы добавить!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          //  есть задачи — показываем список
          : ListView.builder(
              // itemCount колво элементов в списке
              itemCount: _tasks.length,
              // itemBuilder  строит каждый элемент списка
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.circle_outlined), // иконка слева
                  title: Text(_tasks[index]),                 // текст задачи
                  onTap: () => _showTaskDialog(index),        // нажатие на задачу
                );
              },
            ),

      // Нижняя навигационная панель с 2 иконками
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: нет активной вкладки на главном экране (0 = первая)
        // ставим -1 но это вызовет ошибку, поэтому просто не выделяем
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Выполненные',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Архив',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigator.push() — переходим на новый экран
            // MaterialPageRoute — стандартный переход со слайдом
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompletedScreen(
                  completedTasks: _completedTasks,
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArchiveScreen(
                  archivedTasks: _archivedTasks,
                  // onRestore — это коллбек:
                  // передаём функцию как параметр, чтобы ArchiveScreen
                  // вызвал и изменил данные в HomeScreen
                  onRestore: _restoreFromArchive,
                ),
              ),
            );
          }
        },
      ),

      //кнопка "+" в правом нижнем углу
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Добавить задачу',
        child: const Icon(Icons.add),
      ),
    );
  }
}
// ЭКРАН "ВЫПОЛНЕННЫЕ ЗАДАЧИ"
class CompletedScreen extends StatelessWidget {
  // Список получаем из HomeScreen как параметр конструктора.
  final List<String> completedTasks;

  const CompletedScreen({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выполненные задачи'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // leading — виджет слева в AppBar.
        // Стрелка назад 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // возврат на предыдущий экран
        ),
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Text(
                'Нет выполненных задач',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: Text(
                    completedTasks[index],
                    // зачёркнутый текст
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
// ЭКРАН "АРХИВ"
// StatefulWidget потому что  можно восстанавливать
// при восстановлении список меняется, экран надо перерисовать.
class ArchiveScreen extends StatefulWidget {
  final List<String> archivedTasks;
  // строчная функция для коллбека в HomeScreen
  final Function(String) onRestore;

  const ArchiveScreen({
    super.key,
    required this.archivedTasks,
    required this.onRestore,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  // Метод: показать диалог "Восстановить?"
  void _showRestoreDialog(String task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Восстановить?'),
          content: Text(task),
          actions: [
            // нет закрывает диалог
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Нет'),
            ),
            // да восстанавливает задачу
            TextButton(
              onPressed: () {
                // callback из HomeScreen уберёт задачу из архива и добавит в главный спиоск
                widget.onRestore(task);
                // setState чтобы список в архиве экране тоже обновился
                setState(() {});
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архив'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.archivedTasks.isEmpty
          ? const Center(
              child: Text(
                'Архив пуст',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: widget.archivedTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.archive,
                    color: Colors.grey,
                  ),
                  title: Text(
                    widget.archivedTasks[index],
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  // нажать на задачу в архиве открывает диалог восстановления
                  onTap: () => _showRestoreDialog(widget.archivedTasks[index]),
                );
              },
            ),
    );
  }
}