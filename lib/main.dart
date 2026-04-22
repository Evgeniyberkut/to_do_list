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
      home: const MainScreen(), // стартовый экран — "Сегодня"
    );
  }
}
 
 class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
 }

 class _MainScreenState extends State<MainScreen> {
  //какая вкладка активна (1 средняя)
  int _currentIndex = 1;
  //три списка переехади сюда
  final List<String> _tasks = [];
  final List<String> _completedTasks = [];
  final List<String> _archivedTasks = [];

  //метод восстановления переехал сюда
  void _restoreFromArchive(String task) {
    setState(() {
      _archivedTasks.remove(task);
      _tasks.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    //список экранов
    final List<Widget> screens = [
      CompletedScreen(completedTasks: _completedTasks),
      HomeScreen(
        tasks: _tasks, 
        completedTasks: _completedTasks, 
        archivedTasks: _archivedTasks,
        ),
        ArchiveScreen(
          archivedTasks: _archivedTasks, 
          onRestore: _restoreFromArchive,
          ),
    ] ;
    return Scaffold(
      //экран по индексу показ
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; //переключение вкладки
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "Выполнено",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Сегодня",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: "Архив",
            ),
        ]
        ),
    );
  }
}


// ─────────────────────────────────────────────
// меин эеран сегодня
// StatefulWidget — виджет с внутренним состоянием
// используется тк  список задач меняется
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  //cписки из MainScreen
  final List<String> tasks;
  final List<String> completedTasks;
  final List<String> archivedTasks;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.completedTasks,
    required this.archivedTasks,
    });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// класс где хранятся данные 
// Всё с _ это приватное
class _HomeScreenState extends State<HomeScreen> {


  //убрал контроллер из метода и сделал глобальным в классе чтобы не создавать новый каждый раз
  final TextEditingController _textController = TextEditingController();
  
  //добавил диспоуз 
  @override
  void dispose() {
        _textController.dispose(); //осаободил память
    super.dispose(); //выозов родительского класса
  }

  //  диалоговое окно с полем для ввода текста + обновляю метод
  void _showAddTaskDialog() {
    _textController.clear(); // чищу поле
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новая задача'),
          content: TextField(
            controller: _textController, // поле класса
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
                final text = _textController.text.trim(); // trim() убирает лишние пробелы
                if (text.isNotEmpty) {
                  // setState() данные изменились нужно чтобы перерисовался экран
                  setState(() {
                    widget.tasks.add(text);
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
          content: Text(widget.tasks[index]), // показываем текст задачи
          actions: [
            // удалить — задача в Архив
            TextButton(
              onPressed: () {
                setState(() {
                  widget.archivedTasks.add(widget.tasks[index]); // добавляем в архив
                  widget.tasks.removeAt(index);             // удаляем из главного списка
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
                  widget.completedTasks.add(widget.tasks[index]); // добавляем в выполненные
                  widget.tasks.removeAt(index);              // удаляем из главного списка
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
      body: widget.tasks.isEmpty
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
              itemCount: widget.tasks.length,
              // itemBuilder  строит каждый элемент списка
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.circle_outlined), // иконка слева
                  title: Text(widget.tasks[index]),                 // текст задачи
                  onTap: () => _showTaskDialog(index),        // нажатие на задачу
                );
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
  final List<String> completedTasks;

  const CompletedScreen({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выполненные задачи'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // leading — виджет слева в AppBar.
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
class ArchiveScreen extends StatefulWidget {
  final List<String> archivedTasks;
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