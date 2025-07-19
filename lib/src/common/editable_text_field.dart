import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

class EditableTextField extends StatefulWidget {
  final String initialValue;
  final String labelText;
  final Function(String) onSave;
  final bool showSaveCancelButtons;
  final Function(bool)? onEditingStateChanged;

  const EditableTextField({
    super.key,
    required this.initialValue,
    required this.labelText,
    required this.onSave,
    this.showSaveCancelButtons = true,
    this.onEditingStateChanged,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late TextEditingController _controller;
  late String _originalValue;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _originalValue = widget.initialValue;
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(EditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
      _originalValue = widget.initialValue;
      _hasChanges = false;
      _isEditing = false;
    }
  }

  void _onTextChanged() {
    final hasChanges = _controller.text != _originalValue;
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
      // Only notify about editing state if we're actually in editing mode
      if (_isEditing) {
        widget.onEditingStateChanged?.call(_hasChanges);
      }
    }
  }

  void _onSave() {
    // Notify that editing is finished immediately
    widget.onEditingStateChanged?.call(false);
    widget.onSave(_controller.text);
    setState(() {
      _originalValue = _controller.text;
      _hasChanges = false;
      _isEditing = false;
    });
  }

  void _onCancel() {
    // Notify that editing is finished immediately
    widget.onEditingStateChanged?.call(false);
    _controller.text = _originalValue;
    setState(() {
      _hasChanges = false;
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          minLines: 1,
          maxLines: 5,
          onTap: () {
            if (!_isEditing) {
              setState(() {
                _isEditing = true;
              });
              widget.onEditingStateChanged?.call(true);
            }
          },
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            suffixIcon: widget.showSaveCancelButtons && _hasChanges
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: _onSave,
                        tooltip: context.l10n.saveButton,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _onCancel,
                        tooltip: context.l10n.cancel,
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
