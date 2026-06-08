import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'connection_db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    listarTarefas();
  }

  Future<Database> get db async =>
      await ConnectionDb.instance.database;

  Future<void> criarTarefa() async {
    if (controller.text.isEmpty) return;

    final database = await db;

    await database.insert('tasks', {
      'task': controller.text,
      'done': 0,
      'created': DateTime.now().toString(),
    });

    controller.clear();
    listarTarefas();
  }

  Future<void> listarTarefas() async {
    final database = await db;

    tarefas = await database.query('tasks');

    setState(() {});
  }

  Future<Map<String, dynamic>?> buscarPorId(int id) async {
    final database = await db;

    final resultado = await database.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }

    return null;
  }

  Future<void> atualizarTarefa(
      int id, String novaTarefa) async {
    final database = await db;

    await database.update(
      'tasks',
      {'task': novaTarefa},
      where: 'id = ?',
      whereArgs: [id],
    );

    listarTarefas();
  }

  Future<void> deletarTarefa(int id) async {
    final database = await db;

    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    listarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Tarefas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Digite uma tarefa",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: criarTarefa,
              child: const Text("Adicionar"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];

                  return Card(
                    child: ListTile(
                      title: Text(tarefa['task']),
                      subtitle: Text(
                        "ID: ${tarefa['id']}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              atualizarTarefa(
                                tarefa['id'],
                                "${tarefa['task']} (Editada)",
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deletarTarefa(
                                tarefa['id'],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}