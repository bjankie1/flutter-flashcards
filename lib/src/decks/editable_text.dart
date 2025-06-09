import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableText extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final TextStyle? style;

  const EditableText({
    super.key,
    required this.text,
    required this.onTextChanged,
    this.style,
  });

  @override
  State<EditableText> createState() => _EditableTextState();
}

class _EditableTextState extends State<EditableText> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool editing = false;
  bool hovering = false;
  String? originalText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    focusNode = FocusNode();
    focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus && editing) {
      setState(() {
        editing = false;
        controller.text = originalText ?? widget.text;
      });
      focusNode.unfocus();
    }
  }

  void _startEditing() {
    setState(() {
      editing = true;
      originalText = widget.text;
      controller.text = widget.text;
      focusNode.requestFocus();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    });
  }

  void _save() {
    widget.onTextChanged(controller.text);
    setState(() {
      editing = false;
    });
  }

  void _cancel() {
    setState(() {
      editing = false;
      controller.text = originalText ?? widget.text;
    });
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    final borderColor = editing
        ? outline.withOpacity(0.7)
        : (hovering ? outline.withOpacity(0.5) : Colors.transparent);
    final borderWidth = editing ? 1.0 : (hovering ? 1.0 : 1.0);
    final fillColor = editing ? primary.withOpacity(0.08) : Colors.transparent;

    Widget textField;
    if (editing) {
      textField = TextField(
        focusNode: focusNode,
        controller: controller,
        style: widget.style,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        autofocus: true,
        onSubmitted: (value) {
          _save();
        },
      );
    } else {
      textField = GestureDetector(
        onTap: _startEditing,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            style: widget.style,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      );
    }

    textField = MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: textField,
      ),
    );

    if (editing) {
      textField = Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) {
                _cancel();
                return null;
              },
            ),
          },
          child: textField,
        ),
      );
    }

    return Row(
      children: [
        Flexible(child: textField),
        if (editing)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Material(
              color: primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _save,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DismissIntent extends Intent {
  const DismissIntent();
}
