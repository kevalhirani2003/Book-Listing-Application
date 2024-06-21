import 'dart:developer';
import 'package:book_listing_application/cubit/bookcubit.dart';
import 'package:book_listing_application/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class BookListPage extends StatefulWidget {
  BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late BookCubit bookCubit;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    bookCubit = BookCubit(ApiService());
    bookCubit.fetchBooks();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        bookCubit.fetchMoreBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Book List'),
        ),
        body: BlocBuilder<BookCubit, BookState>(
          bloc: bookCubit,
          builder: (context, state) {
            log('state: $state');
            if (state is BookLoading) {
              return _buildLoadingShimmer();
            } else if (state is BookLoaded || state is BookLoadedMore) {
              final books = (state is BookLoaded)
                  ? state.books
                  : (state as BookLoadedMore).books;
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                controller: scrollController,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(books[index].title),
                    subtitle:
                        Text('Download Count: ${books[index].downloadCount}'),
                  );
                },
              );
            } else if (state is BookError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is BookLoadingMore) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                controller: scrollController,
                itemCount: state.books.length + 1,
                itemBuilder: (context, index) {
                  if (index < state.books.length) {
                    return ListTile(
                      title: Text(state.books[index].title),
                      subtitle: Text(
                          'Download Count: ${state.books[index].downloadCount}'),
                    );
                  }
                  return Container(
                    height: 100,
                    width: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
            } else if (state is BookErrorMore) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const Center(
                child: Text('No Data'),
              );
            }
          },
        ));
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 10, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 12,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
