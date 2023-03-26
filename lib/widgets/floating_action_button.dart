import 'package:flutter/material.dart';
import 'package:chitchat/widgets/room_modal.dart';
import 'package:chitchat/utils/utils.dart';

class CustomFloatingActionButton extends StatefulWidget {
  const CustomFloatingActionButton({super.key});

  @override
  FloatingActionButtonState createState() => FloatingActionButtonState();
}

class FloatingActionButtonState extends State<CustomFloatingActionButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation =
        _animationController?.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController?.forward();
      } else {
        _animationController?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: _animation!,
          child: FloatingActionButton(
            heroTag: 'Direct Chat',
            onPressed: () {
              _toggleExpanded();

              showTransparentModalBottomSheet(
                context,
                (context) => const CreateRoomBottomSheet(
                  title: 'Chat Someone',
                  type: SheetType.room,
                  buttonLabel: 'Send',
                  direct: true,
                ),
              );
            },
            tooltip: 'Direct Chat',
            child: const Icon(Icons.chat),
          ),
        ),
        const SizedBox(height: 16),
        ScaleTransition(
          scale: _animation!,
          child: FloatingActionButton(
            heroTag: 'Private Room Chat',
            onPressed: () {
              _toggleExpanded();

              showTransparentModalBottomSheet(
                context,
                (context) => const CreateRoomBottomSheet(
                  title: 'New Room (Private)',
                  type: SheetType.room,
                  buttonLabel: 'Create',
                  direct: true,
                  isPrivate: true,
                ),
              );
            },
            tooltip: 'Private Room Chat',
            child: const Icon(Icons.mail_lock_outlined),
          ),
        ),
        const SizedBox(height: 16),
        ScaleTransition(
          scale: _animation!,
          child: FloatingActionButton(
            heroTag: 'Room Chat',
            onPressed: () {
              _toggleExpanded();

              showTransparentModalBottomSheet(
                context,
                (context) => const CreateRoomBottomSheet(
                  title: 'New Room',
                  type: SheetType.room,
                  buttonLabel: 'Create',
                ),
              );
            },
            tooltip: 'Room Chat',
            child: const Icon(Icons.group_add),
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggleExpanded,
          tooltip: 'Toggle',
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController!,
          ),
        ),
      ],
    );
  }
}
