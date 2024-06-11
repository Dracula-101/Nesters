import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';

part 'sublet_state.dart';
part 'sublet_event.dart';
part 'sublet_bloc.freezed.dart';

class SubletBloc extends Bloc<SubletEvent, SubletState> {
  SubletBloc() : super(const SubletState.initial()) {}
}
