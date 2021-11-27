import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/themes.dart';
import 'add_page_cubit.dart';
import 'add_page_state.dart';

class AddPage extends StatefulWidget {
  final bool needsEditing;
  final int selectedPageIndex;

  const AddPage({
    Key? key,
    required this.needsEditing,
    required this.selectedPageIndex,
  }) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final List _iconsList = [
    Icons.delete_rounded,
    Icons.wash_rounded,
    Icons.wine_bar_rounded,
    Icons.widgets_rounded,
    Icons.stars_rounded,
    Icons.query_builder_rounded,
    Icons.fastfood,
    Icons.headset_rounded,
    Icons.local_movies_rounded,
    Icons.outlet_rounded,
    Icons.offline_bolt_rounded,
    Icons.local_printshop,
    Icons.weekend_rounded,
    Icons.nightlight_round,
    Icons.create_rounded,
    Icons.videogame_asset_rounded,
    Icons.toys_rounded,
    Icons.camera_alt_rounded,
    Icons.train_rounded,
    Icons.text_snippet_rounded,
    Icons.accessibility_rounded,
    Icons.ac_unit_rounded,
    Icons.add_box,
    Icons.account_balance,
  ];

  var _selectedIconIndex;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AddPageCubit>(context).gradientAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = Theme.of(context).colorScheme.secondary;
    final second = Theme.of(context).colorScheme.onSecondary;
    final third = Theme.of(context).colorScheme.secondaryVariant;
    return BlocBuilder<AddPageCubit, AddPageState>(
      builder: (blocContext, state) {
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                first,
                state.isColorChanged ? second : first,
                state.isColorChanged ? third : first,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _appBar(),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _textField(),
                  Expanded(
                    child: _icons(state),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                BlocProvider.of<AddPageCubit>(context).returnToHomePage(
                  widget.needsEditing,
                  widget.selectedPageIndex,
                  _controller.text,
                  _iconsList,
                );
                Navigator.of(context).pop();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(radiusValue),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Create a new page'),
    );
  }

  Widget _textField() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(radiusValue),
        ),
        child: Container(
          height: 70,
          color: Theme.of(context).colorScheme.onPrimary,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
              hintText: 'Name of the Page',
              hintStyle: TextStyle(
                color: Color(0xFFE5E0EF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icons(state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: _iconsList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: (context, i) => _icon(_iconsList[i], i, state),
      ),
    );
  }

  Widget _icon(IconData iconData, int i, state) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ClipOval(
        child: Container(
          color: i == state.selectedIconIndex
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.transparent,
          child: GestureDetector(
            onTap: () => BlocProvider.of<AddPageCubit>(context).setIconIndex(i),
            child: Icon(
              iconData,
              color: Theme.of(context).colorScheme.onBackground,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
