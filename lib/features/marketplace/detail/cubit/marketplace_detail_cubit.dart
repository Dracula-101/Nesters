import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_detail_state.dart';
part 'marketplace_detail_cubit.freezed.dart';

class MarketplaceDetailCubit extends Cubit<MarketplaceDetailState> {
  MarketplaceDetailCubit() : super(MarketplaceDetailState.initial());
}
