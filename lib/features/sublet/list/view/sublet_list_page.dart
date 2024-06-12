import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_list_widget.dart';
import 'package:nesters/theme/theme.dart';

class SubletListPage extends StatelessWidget {
  const SubletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SubletListView(),
      ),
    );
  }
}

class SubletListView extends StatefulWidget {
  const SubletListView({super.key});

  @override
  State<SubletListView> createState() => _SubletListViewState();
}

class _SubletListViewState extends State<SubletListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubletBloc, SubletState>(
      builder: (context, state) {
        return RefreshIndicator(
          child: CustomScrollView(
            slivers: [
              (state.isLoading ?? false)
                  ? _buildLoadingIndicator()
                  : state.error != null
                      ? _buildErrorIndicator(state.error!)
                      : _buildSubletList(state.subletList ?? []),
            ],
          ),
          onRefresh: () {
            context.read<SubletBloc>().add(const SubletEvent.reloadSublet());
            return Future.value();
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorIndicator(Exception error) {
    return SliverFillRemaining(
      child: Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildSubletList(List<SubletModel> sublets) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final sublet = sublets[index];
          return SubletModelWidget(sublet: sublet);
        },
        childCount: sublets.length,
      ),
    );
  }
}
