import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Inicialize o Hive
  await Hive.initFlutter();
  // Abra a box de usuários
  await Hive.openBox('users');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD com Hive',
      home: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final Box _userBox = Hive.box('users');

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _addOrUpdateUser({int? index}) {
    // Atualiza ou adiciona um usuário
    if (index == null) {
      _userBox.add({
        'nome': _nomeController.text,
        'email': _emailController.text,
      });
    } else {
      _userBox.putAt(index, {
        'nome': _nomeController.text,
        'email': _emailController.text,
      });
    }

    // Limpa os campos
    _nomeController.clear();
    _emailController.clear();
    Navigator.pop(context);
  }

  void _showForm({int? index}) {
    // Preenche os campos se for edição
    if (index != null) {
      final user = _userBox.getAt(index);
      _nomeController.text = user['nome'];
      _emailController.text = user['email'];
    }

    // Exibe o formulário
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Novo Usuário' : 'Editar Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _addOrUpdateUser(index: index),
            child: const Text('Salvar'),
          ),
          TextButton(
            onPressed: () {
              _nomeController.clear();
              _emailController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    _userBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD com Hive')),
      body: ValueListenableBuilder(
        valueListenable: _userBox.listenable(),
        builder: (context, box, _) {
          return ListView.builder(
            itemCount: _userBox.length,
            itemBuilder: (context, index) {
              final user = _userBox.getAt(index);
              return ListTile(
                title: Text(user['nome']),
                subtitle: Text('e-mail: ${user['email']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
