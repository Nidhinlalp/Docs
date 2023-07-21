import 'package:doccs/core/colors/colors.dart';
import 'package:doccs/core/common/widgets/alert_box.dart';
import 'package:doccs/core/common/widgets/loader.dart';
import 'package:doccs/featurs/auth/repository/auth_repository.dart';
import 'package:doccs/featurs/document/repository/document_repository.dart';
import 'package:doccs/models/document_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  void deletDoc(String id) {
    String token = ref.read(userProvider)!.token;
    ref.read(documentRepositoryProvider).deleteDocuments(token, id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${ref.watch(userProvider)!.name}'),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.purple,
              size: 25,
            ),
          ),
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add_to_drive),
          ),
          IconButton(
            onPressed: () => showMyDialog(
                context, () => signOut(ref), "Would you like to sign out"),
            icon: const Icon(
              Icons.logout_rounded,
              color: kRedColor,
            ),
          ),
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
          if (snapshot.hasData) {
            return Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 600,
                child: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    DocumentModel document = snapshot.data!.data[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: SizedBox(
                        height: 50,
                        child: InkWell(
                          onTap: () => navigateToDocument(context, document.id),
                          child: !kIsWeb
                              ? Slidable(
                                  key: const ValueKey(0),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        autoClose: true,
                                        onPressed: (context) => showMyDialog(
                                          context,
                                          () => deletDoc(document.id),
                                          "Would you like to delete this document",
                                        ),
                                        backgroundColor:
                                            const Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete_outline_outlined,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        autoClose: true,
                                        onPressed: (context) =>
                                            navigateToDocument(
                                                context, document.id),
                                        backgroundColor:
                                            const Color(0xFF0392CF),
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit_document,
                                        label: 'Edit',
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          document.title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      document.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => deletDoc(document.id),
                                      icon: const Icon(
                                        Icons.delete_forever_rounded,
                                        color: Colors.red,
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
          } else {
            return const Center(
              child: Text('Somthing went wronq'),
            );
          }
        },
      ),
    );
  }
}
