import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:matrix_api_lite/src/generated/model.dart' as matrix_model;

enum SheetType { room, invite }

class CreateRoomBottomSheet extends StatefulWidget {
  final String title;
  final SheetType type;
  final String buttonLabel;

  final String? roomId;
  final bool? direct;
  final bool? isPrivate;

  const CreateRoomBottomSheet({
    super.key,
    required this.title,
    required this.type,
    required this.buttonLabel,
    this.roomId,
    this.direct = false,
    this.isPrivate = false,
  });

  @override
  CreateRoomBottomSheetState createState() => CreateRoomBottomSheetState();
}

class CreateRoomBottomSheetState extends State<CreateRoomBottomSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Type here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        try {
                          final myHost = client.userID?.split(":")[1];

                          switch (widget.type) {
                            case SheetType.room:
                              if (widget.direct ?? false) {
                                await client.startDirectChat(
                                    "${_controller.text.trim()}:$myHost");
                              } else {
                                await client.createRoom(
                                  name: "${_controller.text.trim()}:$myHost",
                                  visibility: widget.isPrivate ?? false
                                      ? matrix_model.Visibility.private
                                      : matrix_model.Visibility.public,
                                );
                              }
                              break;
                            case SheetType.invite:
                              await client.inviteUser(
                                widget.roomId!,
                                "${_controller.text.trim()}:$myHost",
                                reason: "Let's have a talk",
                              );
                              break;
                            default:
                          }

                          _controller.clear();
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                      icon: const Icon(Icons.send_outlined),
                    )),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
