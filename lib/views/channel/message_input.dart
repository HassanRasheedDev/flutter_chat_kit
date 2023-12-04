import 'package:flutter/material.dart';

import '../../styles/text_styles.dart';

class MessageInput extends StatefulWidget {
  final String? placeholder;
  final VoidCallback? onPressPlus;
  final Function(String) onPressSend;
  final Function(String?)? onEditing;
  final Function(String) onChanged;
  final bool? isEditing;
  final inputController = TextEditingController();

  MessageInput({
    this.placeholder,
    this.onPressPlus,
    required this.onPressSend,
    required this.onChanged,
    this.onEditing,
    this.isEditing = false,
    Key? key,
  }) : super(key: key) {
    inputController.text = placeholder ?? '';
  }

  @override
  State<StatefulWidget> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool shouldShowSendButton = false;
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    isEditing = widget.isEditing ?? false;

    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      color: Colors.white,
      child: Column(
        children: [
          _buildMainInput(context),
          const SizedBox(height: 8),
          if (isEditing) _buildAccessoryView(context),
        ],
      ),
    );
  }

  Widget _buildMainInput(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const SizedBox(width: 20),
        if (!isEditing)
          Container(
            margin: const EdgeInsets.only(right: 8, bottom: 3),
            padding: const EdgeInsets.all(4),
            height: 32,
            width: 32,
            child: FloatingActionButton(
              onPressed: widget.onPressPlus,
              backgroundColor: Colors.white,
              elevation: 0,
              child: const Image(
                image: AssetImage('assets/iconAdd@3x.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        Expanded(
          flex: 1,
          child: TextField(
            maxLines: 5,
            minLines: 1,
            // textAlignVertical: TextAlignVertical.bottom,
            controller: widget.inputController,
            decoration: InputDecoration(
              hintText: "Type a message",
              hintStyle: const TextStyle(color: Colors.black54),
              border: const OutlineInputBorder(
                // width: 0.0 produces a thin "hairline" border
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
                //borderSide: const BorderSide(),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
              // contentPadding: EdgeInsets.only(top: 2),
            ),
            onChanged: (text) {
              widget.onChanged(text);
              setState(() {
                shouldShowSendButton = text != '';
              });
            },
          ),
        ),
        if (shouldShowSendButton && !isEditing)
          Container(
            margin: const EdgeInsets.only(left: 8, right: 12, bottom: 8),
            width: 24,
            height: 24,
            child: FloatingActionButton(
              onPressed: () {
                widget.onPressSend(widget.inputController.text);
                widget.inputController.clear();
                setState(() {
                  shouldShowSendButton = false;
                });
              },
              backgroundColor: Colors.white,
              elevation: 0,
              child: const Image(
                image: AssetImage('assets/iconSend@3x.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
          )
        else
          const SizedBox(width: 16)
      ],
    );
  }

  Widget _buildAccessoryView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              if (widget.onEditing != null) widget.onEditing!(null);
              widget.inputController.clear();
              setState(() {
                shouldShowSendButton = false;
                isEditing = false;
              });
            },
            child: const Text(
              'Cancel',
              style: TextStyles.sendbirdButtonPrimary300,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onEditing != null) {
                widget.onEditing!(widget.inputController.text);
              }
              widget.inputController.clear();
              setState(() {
                shouldShowSendButton = false;
                isEditing = false;
              });
            },
            child: const Text('Save', style: TextStyles.sendbirdButtonOnDark1),
            //color: SBColors.primary_300,
            //textColor: Colors.white,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(4.0),
            // ),
          ),
        ],
      ),
    );
  }
}
