import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: HomeView(),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchBarController = TextEditingController();
  final FirestoreRepository _firestoreRepository =
      GetIt.I<FirestoreRepository>();
  final GlobalKey _universityListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchBarController.addListener(_rebuildUniversityList);
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSearchBar(),
        _buildUniversityList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: _searchBarController,
          decoration: InputDecoration(
            hintText: 'Search for a university',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUniversityList() {
    return StreamBuilder(
      key: _universityListKey,
      stream: _firestoreRepository.queryCollection(
          'universities', 'title', _searchBarController.text),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final university = snapshot.data?[index];
                return ListTile(
                  title: Text(university?['title']),
                  subtitle: Text(university?['location']),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () {},
                  ),
                );
              },
              childCount: snapshot.data?.length,
            ),
          );
        }
        return SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _rebuildUniversityList() {
    final universityList = _universityListKey.currentContext;
    if (universityList != null) {
      _universityListKey.currentState?.setState(() {});
    }
  }
}
