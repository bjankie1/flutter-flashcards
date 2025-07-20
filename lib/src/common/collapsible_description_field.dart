import 'package:flutter/material.dart';

class CollapsibleDescriptionField extends StatefulWidget {
  final String? text;
  final Function(String) onTextChanged;
  final String addButtonText;
  final String label;
  final String hint;
  final TextStyle? style;
  final bool isLoading;

  const CollapsibleDescriptionField({
    super.key,
    this.text,
    required this.onTextChanged,
    required this.addButtonText,
    required this.label,
    required this.hint,
    this.style,
    this.isLoading = false,
  });

  @override
  State<CollapsibleDescriptionField> createState() =>
      _CollapsibleDescriptionFieldState();
}

class _CollapsibleDescriptionFieldState
    extends State<CollapsibleDescriptionField>
    with TickerProviderStateMixin {
  late TextEditingController controller;
  late FocusNode focusNode;
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;
  bool isExpanded = false;
  bool isEditing = false;
  String? _originalText;

  @override
  void initState() {
    super.initState();
    _originalText = widget.text;
    controller = TextEditingController(text: widget.text ?? '');
    focusNode = FocusNode();
    focusNode.addListener(_handleFocusChange);
    isExpanded = widget.text != null && widget.text!.isNotEmpty;

    // Initialize loading animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(CollapsibleDescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _originalText = widget.text;
      controller.text = widget.text ?? '';
      isExpanded = widget.text != null && widget.text!.isNotEmpty;
      isEditing = false;
    }

    // Handle loading state changes
    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingAnimationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadingAnimationController.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus && isEditing) {
      setState(() {
        isEditing = false;
      });
    }
  }

  bool get _hasUnsavedChanges {
    final currentText = controller.text.trim();
    final originalText = _originalText ?? '';
    return currentText != originalText;
  }

  void _expandField() {
    setState(() {
      isExpanded = true;
      isEditing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _save() {
    final text = controller.text.trim();
    widget.onTextChanged(text);
    setState(() {
      _originalText = text;
      isEditing = false;
      if (text.isEmpty) {
        isExpanded = false;
      }
    });
  }

  void _cancel() {
    setState(() {
      isEditing = false;
      controller.text = _originalText ?? '';
    });
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    if (!isExpanded) {
      return OutlinedButton.icon(
        onPressed: _expandField,
        icon: const Icon(Icons.add, size: 16),
        label: Text(widget.addButtonText),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: outline.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            widget.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              Color borderColor;
              double borderWidth;

              if (widget.isLoading) {
                // Material Design 3 expressive loading border
                final animationValue = _loadingAnimation.value;
                final alpha = 0.3 + (0.7 * animationValue);
                borderColor = theme.colorScheme.primary.withOpacity(alpha);
                borderWidth = 1.5 + (0.5 * animationValue);
              } else {
                borderColor = isEditing ? primary : outline.withOpacity(0.3);
                borderWidth = 1;
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: borderWidth),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: widget.style ?? theme.textTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                        isDense: true,
                        suffixIcon: widget.isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: (value) => _save(),
                      onChanged: (value) {
                        setState(() {
                          // Trigger rebuild to show/hide save/cancel buttons
                        });
                      },
                    ),
                    if (_hasUnsavedChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.isLoading) ...[
                              // Material Design 3 expressive loading indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Saving...',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              IconButton(
                                onPressed: _cancel,
                                icon: const Icon(Icons.close, size: 20),
                                tooltip: 'Cancel',
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: _save,
                                icon: const Icon(Icons.check, size: 20),
                                tooltip: 'Save',
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
