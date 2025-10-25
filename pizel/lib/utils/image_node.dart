import 'dart:io';
import 'dart:collection';

final class ImageNode extends LinkedListEntry<ImageNode> {
  File file;
  ImageNode(this.file);
}