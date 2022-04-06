import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/animations/animations.dart';
import 'package:liso/core/utils/console.dart';
import 'package:supercharged/supercharged.dart';

dynamic selectedData;

class SelectorSheet extends StatelessWidget with ConsoleMixin {
  final List<SelectorItem> items;
  final List<dynamic>? values;
  final dynamic activeId;
  final double? height;

  const SelectorSheet({
    Key? key,
    required this.items,
    this.values,
    this.activeId,
    this.height,
  }) : super(key: key);

  Future<dynamic> show() async {
    selectedData = null;

    await Get.bottomSheet(
      height == null ? this : SizedBox(height: height, child: this),
      isScrollControlled: height != null,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );

    return selectedData;
  }

  @override
  Widget build(BuildContext context) {
    var _items = items;

    if (values != null) {
      _items = values!
          .map(
            (e) => SelectorItem(title: e.toString(), id: e, data: e),
          )
          .toList();
    }

    Widget _itemBuilder(context, index) {
      final data = _items[index];

      void _onTap() {
        Get.back();
        selectedData = data.data ?? data.id;
        data.onSelected?.call();
      }

      final _trailing = activeId != null && data.id == activeId
          ? const Icon(Icons.check_circle)
          : null;

      final _content = ListTile(
        title: Text(data.title),
        subtitle: data.subTitle != null ? Text(data.subTitle!) : null,
        leading: data.leading,
        trailing: data.trailing ?? _trailing,
        onTap: _onTap,
      );

      return ListItemAnimation(
        child: _content,
        delay: 100.milliseconds,
        duration: 300.milliseconds,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: _itemBuilder,
      padding: const EdgeInsets.all(15),
    );
  }
}

class SelectorItem {
  final String title;
  final String? subTitle;
  final Widget? leading;
  final Widget? trailing;
  final dynamic id;
  final dynamic data;
  final Function? onSelected;

  const SelectorItem({
    required this.title,
    this.subTitle,
    this.leading,
    this.trailing,
    this.id,
    this.data,
    this.onSelected,
  });
}
