part of 'widgets.dart';

class DegreesLoader extends StatefulWidget {
  final Widget Function(BuildContext context, List<Degree> degrees) builder;
  const DegreesLoader({super.key, required this.builder});

  @override
  State<DegreesLoader> createState() => _DegreesLoaderState();
}

class _DegreesLoaderState extends State<DegreesLoader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return state.degreesState.exception != null
            ? ShowErrorWidget(
                error: state.degreesState.exception,
                onRetry: () {
                  context.read<AppBloc>().add(const AppEvent.loadDegrees());
                },
              )
            : state.degreesState.isLoading && state.degrees.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state.degrees.isEmpty
                    ? const ShowNoInfoWidget(
                        title: 'No degrees found',
                        subtitle:
                            'There are no degrees available at the moment, please try again later',
                      )
                    : widget.builder(context, state.degrees);
      },
    );
  }
}
