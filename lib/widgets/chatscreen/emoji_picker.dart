import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

class EmojiPickerWidget extends StatelessWidget {
  final TextEditingController textcontroller;

  const EmojiPickerWidget({Key key, this.textcontroller}) : super(key: key);

  void _onEmojiSelected(Emoji emoji, Category _) {
    textcontroller.text = textcontroller.text + emoji.emoji;
    textcontroller.selection = TextSelection.fromPosition(
        TextPosition(offset: textcontroller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      rows: 4,
      columns: 7,
      onEmojiSelected: _onEmojiSelected,
      buttonMode: ButtonMode.MATERIAL,
    );
  }
}
