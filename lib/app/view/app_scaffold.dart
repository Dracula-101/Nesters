import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/theme/theme.dart';

class RootAppScaffold extends StatelessWidget {
  const RootAppScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('AppScaffold'),
      child: Theme(
        data: AppTheme.lightTheme,
        child: DefaultTextStyle(
          style: AppTheme.lightTheme.textTheme.bodyMedium!,
          child: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return child;
            },
          ),
        ),
      ),
    );
  }
}
