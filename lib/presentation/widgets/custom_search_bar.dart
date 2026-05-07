import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final bool isTitle;
  final Function(String) onChanged;
  final String title;
  final FocusNode focus;
  final TextEditingController controllerTiltle;
  final VoidCallback onCancel;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomSearchBar({
    super.key,
    required this.isTitle,
    required this.onCancel,
    required this.onChanged,
    required this.focus,
    required this.controllerTiltle,
    required this.title,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: widget.isTitle ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: Center(child: Text(widget.title)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                clipBehavior: Clip.hardEdge,
                color:
                    widget.backgroundColor ??
                    Theme.of(context).appBarTheme.backgroundColor,
                duration: Duration(milliseconds: 300),
                width: widget.isTitle ? 0 : constraints.maxWidth,
                child: OverflowBox(
                  maxWidth: constraints.maxWidth,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar Producto...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: widget.controllerTiltle.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.controllerTiltle.clear();
                                  widget.onCancel();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,

                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: widget.borderColor ?? Colors.white70,
                          width: 2,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: widget.borderColor ?? Colors.white70,
                          width: 2,
                        ),
                      ),
                    ),
                    focusNode: widget.focus,
                    controller: widget.controllerTiltle,
                    onChanged: (value) {
                      setState(() {
                        widget.onChanged(value);
                      });
                    },
                    cursorColor: widget.borderColor ?? Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
