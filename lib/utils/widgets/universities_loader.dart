part of 'widgets.dart';

class UniversitiesLoader extends StatefulWidget {
  final Widget Function(BuildContext context, List<University> universities)
      builder;
  const UniversitiesLoader({super.key, required this.builder});

  @override
  State<UniversitiesLoader> createState() => _UniversitiesLoaderState();
}

class _UniversitiesLoaderState extends State<UniversitiesLoader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return state.universitiesState.exception != null
            ? ShowErrorWidget(
                error: state.universitiesState.exception,
                onRetry: () {
                  context
                      .read<AppBloc>()
                      .add(const AppEvent.loadUniversities());
                },
              )
            : state.universitiesState.isLoading
                ? Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            context
                                .read<AppBloc>()
                                .add(const AppEvent.loadUniversities());
                          },
                          child: const Text('Reload'),
                        ),
                      ],
                    ),
                  )
                : state.universities.isEmpty
                    ? const ShowNoInfoWidget(
                        title: 'No universities found',
                        subtitle:
                            'There are no universities available at the moment, please try again later',
                      )
                    : widget.builder(context, state.universities);
      },
    );
  }
}
