import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sublet_detail_state.dart';
part 'sublet_detail_cubit.freezed.dart';

class SubletDetailCubit extends Cubit<SubletDetailState> {
  SubletDetailCubit() : super(SubletDetailState.initial());
}
