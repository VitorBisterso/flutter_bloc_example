import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc_example/models/user.dart';
import 'package:bloc_example/blocs/user_list/user_list_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void showBottomSheet({
    required BuildContext context,
    required int id,
    bool isEdit = false,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  controller: _nameController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  controller: _emailController,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final user = User(
                        id: id,
                        name: _nameController.text,
                        email: _emailController.text,
                      );

                      if (isEdit) {
                        context
                            .read<UserListBloc>()
                            .add(UpdateUser(user: user));
                      } else {
                        context.read<UserListBloc>().add(AddUser(user: user));
                      }
                      Navigator.pop(context);
                    },
                    child: Text(isEdit ? 'Update' : 'Add user'),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget buildUserTile(BuildContext context, User user) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              context.read<UserListBloc>().add(DeleteUser(user: user));
            },
            icon: const Icon(Icons.delete, size: 30),
          ),
          IconButton(
            onPressed: () {
              _nameController.text = user.name;
              _emailController.text = user.email;
              showBottomSheet(
                context: context,
                id: user.id,
                isEdit: true,
              );
            },
            icon: const Icon(Icons.edit, size: 30),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc example'),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          final state = context.read<UserListBloc>().state;
          final id = state.users.length + 1;
          showBottomSheet(context: context, id: id);
        },
        child: const Text('Add user'),
      ),
      // type of bloc, type of state
      // bloc builder rebuilds child widget tree when state changes
      body: BlocBuilder<UserListBloc, UserListState>(
        // called when state of bloc changes
        builder: (ctx, state) {
          if (state is UserListUpdated && state.users.isNotEmpty) {
            final users = state.users;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctxt, index) {
                final user = users[index];
                return buildUserTile(ctxt, user);
              },
            );
          } else {
            return const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text('No users found'),
              ),
            );
          }
        },
      ),
    );
  }
}
