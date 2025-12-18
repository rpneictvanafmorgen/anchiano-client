import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<Locale?> {
  LanguageCubit() : super(null);

  void setDutch() => emit(const Locale('nl'));
  void setEnglish() => emit(const Locale('en'));
}
