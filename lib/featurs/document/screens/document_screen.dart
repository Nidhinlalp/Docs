// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:doccs/core/colors/colors.dart';
import 'package:doccs/core/common/widgets/loader.dart';
import 'package:doccs/featurs/auth/repository/auth_repository.dart';
import 'package:doccs/featurs/document/repository/document_repository.dart';
import 'package:doccs/featurs/document/repository/socket_repository.dart';
import 'package:doccs/models/error_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/document_model.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    super.key,
    required this.id,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titelController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller?.compose(
        quill.Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.REMOTE,
      );
    });
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      titelController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    // _controller!.document.changes.listen((event) {
    //   if (event.before == quill.ChangeSource.LOCAL) {
    //     Map<String, dynamic> map = {
    //       'delta': event.change,
    //       'room': widget.id,
    //     };
    //     socketRepository.typing(map);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    titelController.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/docs-logo.png',
                height: 35,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: size.width * 0.3,
                child: TextField(
                  onSubmitted: (value) => updateTitle(ref, value),
                  controller: titelController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.purple,
                    )),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
              )
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kGreyColor, width: 0.1),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link copied!',
                        ),
                      ),
                    );
                  },
                );
              },
              label: const Text('Share'),
              icon: const Icon(Icons.lock),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillToolbar.basic(controller: _controller!),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller!,
                        readOnly: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
