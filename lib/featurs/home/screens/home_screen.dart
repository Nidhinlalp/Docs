import 'package:doccs/core/colors/colors.dart';
import 'package:doccs/core/common/widgets/loader.dart';
import 'package:doccs/featurs/auth/repository/auth_repository.dart';
import 'package:doccs/featurs/document/repository/document_repository.dart';
import 'package:doccs/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  Future<void> createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${ref.watch(userProvider)!.name}'),
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add_to_drive),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(
              Icons.logout_rounded,
              color: kRedColor,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: ref
            .watch(documentRepositoryProvider)
            .getDocuments(ref.watch(userProvider)!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DocumentModel document = snapshot.data!.data[index];

                  return snapshot.data!.data.length == 0
                      ? const Center(
                          child: Text('Create Own Your Doc'),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 50,
                            child: InkWell(
                              onTap: () =>
                                  navigateToDocument(context, document.id),
                              child: Card(
                                child: Center(
                                  child: Text(
                                    document.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
