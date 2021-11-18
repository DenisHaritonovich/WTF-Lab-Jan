import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_state.dart';

class EditCubit extends Cubit<EditState> {
  EditCubit(EditState state) : super(state);

  void changeIcon(int iconIndex) {
    final updatedState = state.copyWith(page: state.page.copyWith(iconIndex: iconIndex, title: ''));
    emit(updatedState);
  }

  void updateAllowance(String text) {
    final isAllowedToSave = text.isNotEmpty;
    final updatedState = state.copyWith(isAllowedToSave: isAllowedToSave);
    emit(updatedState);
  }

  void renamePage(String name) {
    emit(state.copyWith(page: state.page.copyWith(title: name, iconIndex: 0)));
  }
}
