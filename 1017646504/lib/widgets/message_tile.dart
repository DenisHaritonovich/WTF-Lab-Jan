import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';
import 'package:intl/intl.dart';

import '../data/icons.dart';
import '../entity/page.dart';
import '../main_pages/home/message_page/messages_cubit.dart';
import '../main_pages/settings_page/settings_cubit.dart';

class MessageTile extends StatefulWidget {
  final Event _event;
  final bool _isRightToLeft;
  final bool _isSelected;
  final bool _slidable;
  final Function(String)? onHashTap;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function(Event)? onDelete;
  final Function(Event)? onEdit;

  MessageTile(
    this._event,
    this._isRightToLeft,
    this._slidable,
    this._isSelected, {
    this.onHashTap,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
  }) : super(key: ValueKey(_event.id));

  @override
  _MessageTileState createState() => _MessageTileState(
        _event,
        _isRightToLeft,
        _slidable,
        _isSelected,
        onTap: onTap,
        onLongPress: onLongPress,
        onHashTap: onHashTap,
        onEdit: onEdit,
        onDelete: onDelete,
      );
}

class _MessageTileState extends State<MessageTile> with SingleTickerProviderStateMixin {
  final Event _event;
  final bool _isRightToLeft;
  bool _isSelected;
  final bool _slidable;
  final Function(String)? onHashTap;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function(Event)? onDelete;
  final Function(Event)? onEdit; ////////////////////////////////////////////убрать функции

  _MessageTileState(
    this._event,
    this._isRightToLeft,
    this._slidable,
    this._isSelected, {
    this.onHashTap,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
  });

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInBack,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isSelected = BlocProvider.of<MessageCubit>(context).state.selected.contains(_event);

    Widget _title(Event event) {
      return Row(
        children: [
          Icon(
            eventIconList[event.iconIndex],
            color: Theme.of(context).textTheme.bodyText2!.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              eventStringList[event.iconIndex],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText2!.color,
                fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
              ),
            ),
          )
        ],
      );
    }

    Widget _content(Event event) {
      return event.imagePath.isEmpty
          ? HashTagText(
              text: event.description,
              basicStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText2!.color,
                fontSize: SettingsCubit.calculateSize(context, 12, 15, 20),
              ),
              decoratedStyle: TextStyle(
                color: Colors.yellowAccent,
                fontSize: SettingsCubit.calculateSize(context, 12, 15, 20),
              ),
              onTap: onHashTap,
            )
          : Image.file(File(event.imagePath));
    }

    Widget _container() => SlideTransition(
          position: _offsetAnimation,
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: AnimatedContainer(
              margin: _isRightToLeft
                  ? const EdgeInsets.only(top: 2, bottom: 2, left: 100, right: 5)
                  : const EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  bottomLeft: _isRightToLeft ? const Radius.circular(10) : Radius.zero,
                  topRight: const Radius.circular(10),
                  bottomRight: _isRightToLeft ? Radius.zero : const Radius.circular(10),
                ),
                color: _isSelected ? Theme.of(context).shadowColor : Theme.of(context).accentColor,
              ),
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                bottom: 5,
              ),
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_event.iconIndex != 0) _title(_event),
                  _content(_event),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _event.isFavourite
                            ? const Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.yellowAccent,
                                  size: 12,
                                ),
                              )
                            : Container(),
                      ),
                      Text(
                        DateFormat('HH:mm').format(_event.creationTime),
                        style: TextStyle(
                          fontSize: SettingsCubit.calculateSize(context, 10, 12, 20),
                          color: Theme.of(context).textTheme.bodyText2!.color,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

    return _slidable
        ? Slidable(
            actionPane: const SlidableScrollActionPane(),
            actions: [
              IconSlideAction(
                caption: 'Edit',
                color: Theme.of(context).primaryColor,
                icon: Icons.edit_outlined,
                onTap: () => onEdit!(_event),
                closeOnTap: true,
              )
            ],
            secondaryActions: [
              IconSlideAction(
                caption: 'Delete',
                color: Theme.of(context).primaryColor,
                icon: Icons.delete_outlined,
                onTap: () async {
                  await _controller.forward();
                  onDelete!(_event);
                },
                closeOnTap: true,
              )
            ],
            child: _container(),
          )
        : _container();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
