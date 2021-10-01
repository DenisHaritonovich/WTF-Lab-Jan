import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../color_theme_cubit.dart';
import '../data/icons.dart';
import '../edit_page/edit_page.dart';
import '../entity/page.dart';
import '../message_page/message_page.dart';
import '../settings_page/settings_cubit.dart';
import '../settings_page/settings_page.dart';
import 'pages_cubit.dart';

class MainPage extends StatelessWidget {
  MainPage();

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PagesCubit>(context).initialize();
    return _scaffold(context);
  }

  Widget _scaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Chat Journal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyText2!.color,
            fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
          ),
        ),
        iconTheme: Theme.of(context).accentIconTheme,
        actions: [
          _themeChangeButton(context),
        ],
      ),
      drawer: _drawer(context),
      bottomNavigationBar: _bottomNavigationBar(context),
      floatingActionButton: _floatingActionButton(context),
      body: BlocBuilder<PagesCubit, List<JournalPage>>(
        builder: (context, state) => _body(context),
      ),
    );
  }

  Widget _themeChangeButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        BlocProvider.of<ColorThemeCubit>(context).state.usingLightTheme
            ? Icons.wb_sunny_outlined
            : Icons.bedtime_outlined,
      ),
      onPressed: BlocProvider.of<ColorThemeCubit>(context).changeTheme,
    );
  }

  Widget _drawer(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).primaryColor,
      ),
      child: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
              child: Text(
                DateFormat('MMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2!.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
      currentIndex: 0,
      backgroundColor: Theme.of(context).accentColor,
      selectedItemColor: Theme.of(context).textTheme.bodyText2!.color,
      unselectedItemColor: Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.3),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
      onPressed: () async {
        final pageInfo = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPage(
              JournalPage('New page', 0, creationTime: DateTime.now()),
              'New page',
            ),
          ),
        );
        if (pageInfo.isAllowedToSave) {
          BlocProvider.of<PagesCubit>(context).addPage(pageInfo.page);
          BlocProvider.of<PagesCubit>(context).state.forEach((element) {});
        }
      },
      backgroundColor: Theme.of(context).accentColor,
      tooltip: 'New page',
      child: const Icon(Icons.add),
    );
  }

  Widget _body(BuildContext context) {
    return BlocProvider.of<PagesCubit>(context).state.isEmpty
        ? Center(
            child: Text(
              'No pages yet...',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5),
                fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
              ),
            ),
          )
        : _gridView(context);
  }

  void _pageModalBottomSheet(BuildContext context, int index) {
    final selected = BlocProvider.of<PagesCubit>(context).state[index];

    TextStyle _style() {
      return TextStyle(
        color: Theme.of(context).textTheme.bodyText1!.color,
        fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
      );
    }

    Widget _pinTile() {
      return ListTile(
          leading: Transform.rotate(
            angle: 45 * pi / 180,
            child: Icon(
              Icons.push_pin_outlined,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          title: Text(
            selected.isPinned ? 'Unpin' : 'Pin',
            style: _style(),
          ),
          onTap: () async {
            BlocProvider.of<PagesCubit>(context).pinPage(selected);
            Navigator.pop(context);
          });
    }

    Widget _editTile() {
      return ListTile(
          leading: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          title: Text(
            'Edit',
            style: _style(),
          ),
          onTap: () async {
            final editState = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(
                      JournalPage(selected.title, selected.iconIndex, creationTime: DateTime.now()),
                      'Edit',
                    ),
                  ),
                ) ??
                false;
            if (editState.isAllowedToSave) {
              BlocProvider.of<PagesCubit>(context).editPage(selected, editState._page);
            }
            Navigator.pop(context);
          });
    }

    Widget _deleteTile() {
      return ListTile(
          leading: Icon(
            Icons.delete_outlined,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          title: Text(
            'Delete',
            style: _style(),
          ),
          onTap: () {
            BlocProvider.of<PagesCubit>(context).deletePage(selected);
            Navigator.pop(context);
          });
    }

    Widget _infoTile() {
      Widget _alertDialog() {
        Widget _pageInfo() {
          return Row(
            children: [
              CircleAvatar(
                maxRadius: 20,
                foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  iconList[selected.iconIndex],
                ),
              ),
              Expanded(
                child: Text(
                  selected.title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }

        Widget _content() {
          Widget _infoTile(String header, DateTime? time) {
            return Column(
              children: [
                Text(
                  '$header:',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color,
                    fontWeight: FontWeight.bold,
                    fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(time!),
                  style: _style(),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: _infoTile('Creation time', selected.creationTime),
              ),
              if (selected.lastEvent != null)
                _infoTile('Last event', selected.lastEvent!.creationTime),
            ],
          );
        }

        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
              color: Theme.of(context).accentColor,
            ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: _pageInfo(),
          ),
          content: _content(),
        );
      }

      return ListTile(
          leading: Icon(
            Icons.info_outline,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          title: Text(
            'Info',
            style: _style(),
          ),
          onTap: () async {
            Navigator.pop(context);
            await showDialog(
              context: context,
              builder: (context) => _alertDialog(),
            );
          });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            _pinTile(),
            _editTile(),
            _deleteTile(),
            _infoTile(),
          ],
        );
      },
    );
  }

  Widget _gridView(BuildContext context) {
    return StaggeredGridView.extentBuilder(
      maxCrossAxisExtent: 300,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: BlocProvider.of<PagesCubit>(context).state.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagePage(
                  BlocProvider.of<PagesCubit>(context).state[index],
                ),
              ),
            );
            BlocProvider.of<PagesCubit>(context).updatePages();
          },
          onLongPress: () {
            _pageModalBottomSheet(context, index);
          },
          child: _gridViewItem(BlocProvider.of<PagesCubit>(context).state[index], context),
        );
      },
      staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
    );
  }

  Widget _gridViewItem(JournalPage page, BuildContext context) {
    Widget _header() {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              iconList[page.iconIndex],
              color: Theme.of(context).textTheme.bodyText2!.color,
            ),
            Expanded(
              child: Text(
                page.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText2!.color,
                ),
              ),
            ),
            if (page.isPinned)
              Align(
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: 45 * pi / 180,
                  child: Icon(
                    Icons.push_pin_outlined,
                    color: Theme.of(context).textTheme.bodyText2!.color,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget _content() {
      return Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(10),
        child: page.lastEvent == null
            ? Center(
                child: Text(
                  'No events yet...',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5),
                    fontSize: SettingsCubit.calculateSize(context, 15, 20, 30),
                  ),
                ),
              )
            : Text(
                page.lastEvent!.description,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color,
                  fontSize: SettingsCubit.calculateSize(context, 12, 15, 20),
                ),
              ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: Column(
        children: [
          _header(),
          _content(),
        ],
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
