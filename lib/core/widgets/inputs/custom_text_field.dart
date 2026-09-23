import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.style,
    this.labelKey,
    this.hintKey,
    this.hint,
    this.hideHintOnFocus = true,
    this.height,
    this.validators,
    this.formatters,
    this.autoFillHints,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.filled = true,
    this.fillColor,
    this.expands = false,
    this.obscureText = false,
    this.disabled = false,
    this.readOnly = false,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.enableSelection = true,
    this.unFocusWhenTapOutside = true,
    this.textAlignVertical = TextAlignVertical.center,
    this.textAlign = TextAlign.start,
    this.textInputType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.onChanged,
    this.onSubmit,
    this.floatingLabelBehavior,
    super.key,
  });

  ///A custom made text controller that provides a validate method to validate
  ///the content of [CustomTextField] associated with the controller
  final TextController controller;
  final FocusNode? focusNode;
  final bool autofocus;

  final String? labelKey;
  final String? hintKey;
  final Widget? hint;

  /// Used only for [hint] property
  final bool hideHintOnFocus;

  final TextStyle? style;

  ///List of rules that the content of [CustomTextField] must adhere to
  final List<Validator<String?>>? validators;
  final List<TextInputFormatter>? formatters;
  final List<String>? autoFillHints;

  final double? height;
  final bool readOnly;

  /// Fixed text inside the field that is not part of [controller]'s value
  /// (e.g. a currency symbol) — unlike a formatter-injected symbol it can't
  /// be deleted or selected. Rendered through the icon slots rather than
  /// `InputDecoration.prefixText`, which hides itself while the field is
  /// empty and unfocused (so it never showed on a fresh offer). Ignored when
  /// the matching icon is set.
  final String? prefixText;
  final String? suffixText;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool filled;
  final Color? fillColor;
  final bool obscureText;
  final bool expands;
  final bool disabled;
  final bool enableSelection;
  final bool unFocusWhenTapOutside;
  final TextAlignVertical textAlignVertical;
  final TextAlign textAlign;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String?>? onSubmit;
  final FloatingLabelBehavior? floatingLabelBehavior;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = false;
  bool isValid = true;
  late final FocusNode _focusNode =
      widget.focusNode ?? FocusNode(canRequestFocus: false);
  final ValueNotifier<bool> _isHintShowing = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText;
    widget.controller._registerValidators(
      widget.validators ?? [EmptyFieldValidator()],
    );
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          isValid = widget.controller._isValid.value;
        });
      }
    });

    if (widget.hideHintOnFocus && widget.hint != null) {
      _focusNode.addListener(() {
        _isHintShowing.value = !_isHintShowing.value;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _isHintShowing.dispose();
    widget.controller._clearValidators();
    super.dispose();
  }

  Widget? _affix(String? text) {
    if (text == null) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text, style: widget.style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: widget.autofocus,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.textInputType,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      style: widget.style,
      obscureText: isObscure,
      obscuringCharacter: '*',
      expands: widget.expands,
      minLines: widget.expands ? null : widget.minLines,
      maxLines: widget.expands ? null : widget.maxLines,
      textAlignVertical: widget.textAlignVertical,
      textAlign: widget.textAlign,
      enableInteractiveSelection: widget.enableSelection,
      inputFormatters: widget.formatters,
      textCapitalization: widget.textCapitalization,
      textInputAction: TextInputAction.next,
      maxLength: widget.maxLength,
      autofillHints: widget.autoFillHints,
      decoration: InputDecoration(
        filled: widget.filled,
        fillColor: widget.fillColor,
        border: widget.border,
        enabledBorder: widget.enabledBorder,
        focusedBorder: widget.focusedBorder,
        floatingLabelBehavior: widget.floatingLabelBehavior,
        errorText: widget.controller._errorText != null
            ? widget.controller._errorText!.translate(context)
            : null,
        errorMaxLines: 2,
        prefixIcon: widget.prefixIcon ?? _affix(widget.prefixText),
        prefixIconConstraints:
            widget.prefixIconConstraints ??
            (widget.prefixText != null ? const BoxConstraints() : null),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() {
                  isObscure = !isObscure;
                }),
                icon: Icon(
                  isObscure ? AppIcons.eye : AppIcons.eyeSlash,
                  size: 25,
                ),
              )
            : widget.suffixIcon ?? _affix(widget.suffixText),
        suffixIconConstraints:
            widget.suffixIconConstraints ??
            (widget.suffixText != null ? const BoxConstraints() : null),
        labelText: widget.labelKey != null
            ? widget.labelKey!.translate(context)
            : null,
        hintText: widget.hintKey != null
            ? widget.hintKey!.translate(context)
            : null,
        hintStyle:
            widget.style?.copyWith(
              color: widget.style?.color?.withValues(alpha: .5),
            ) ??
            context.theme.inputDecorationTheme.hintStyle,
        hint: widget.hint != null
            ? ValueListenableBuilder(
                valueListenable: _isHintShowing,
                builder: (context, value, child) =>
                    value ? child! : const SizedBox.shrink(),
                child: widget.hint,
              )
            : null,
        maintainHintSize: false,
        constraints: BoxConstraints(
          maxHeight: widget.height ?? double.maxFinite,
          minHeight: widget.height ?? 0,
        ),
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmit,
      onTapOutside: widget.unFocusWhenTapOutside
          ? (event) {
              _focusNode.unfocus();
            }
          : null,
    );
  }
}

///Custom controller to validate the content of [TextField] and avoid using [Form]
///as that will require to use [GlobalKey] for every [TextField] we have.
///
///Optimizes the additional checks when submitting the data and avoids using
///[SnackBar] unnecessarily
class TextController extends TextEditingController {
  TextController({super.text});

  ///List of [Validator] that must return true for the content to be considered as true
  final List<Validator<String?>> _validators = [];

  ///Used to change the state of [CustomTextField] internally
  final ValueNotifier<bool> _isValid = ValueNotifier<bool>(true);

  ///The error text that should be displayed when any of the validator returns false
  String? _errorText;

  ///Register the list of [Validator] to be used when validating the content of associated field
  void _registerValidators(List<Validator<String?>> validators) {
    _validators.clear();
    _validators.addAll(validators);
  }

  void _clearValidators() {
    _validators.clear();
  }

  ///Iterates over each registered validators and checks if the content passes all the rules
  bool validate() {
    _isValid.value = _validators.every((element) {
      if (!element.validate(text)) {
        _errorText = element.errorText;
        return false;
      } else {
        _errorText = null;
        return true;
      }
    });
    notifyListeners();
    return _isValid.value;
  }

  @override
  void clear() {
    super.clear();
    if (!_isValid.value) {
      _isValid.value = true;
      _errorText = null;
    }
  }
}
