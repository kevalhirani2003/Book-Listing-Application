import 'dart:developer';

import 'package:book_listing_application/datamodel/bookmodel.dart';
import 'package:book_listing_application/services/apiservice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<Book> books;
  final String nextPageUrl;

  BookLoaded(this.books, this.nextPageUrl);
}

class BookError extends BookState {
  final String message;

  BookError(this.message);
}

class BookLoadingMore extends BookState {
  final List<Book> books;
  final String nextPageUrl;

  BookLoadingMore({required this.books, required this.nextPageUrl});
}

class BookLoadedMore extends BookState {
  final List<Book> books;
  final String nextPageUrl;

  BookLoadedMore(this.books, this.nextPageUrl);
}

class BookErrorMore extends BookState {
  final String message;
  final List<Book> books;
  final String nextPageUrl;

  BookErrorMore(this.message, this.books, this.nextPageUrl);
}

class BookNoMore extends BookState {}

class BookCubit extends Cubit<BookState> {
  List<Book> oldBooks = [];

  BookCubit() : super(BookInitial());

  final ApiService apiService = ApiService();

  void fetchBooks() async {
    emit(BookLoading());
    try {
      final result = await apiService.fetchBook(1);
      oldBooks = result.book;
      emit(BookLoaded(result.book, result.next));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  void fetchMoreBooks() async {
    final currentState = state;
    log('currentState: $currentState');

// Sir in this code the current state is checked and the next page url is selected based on the current state
    if (currentState is BookLoaded ||
        currentState is BookLoadedMore ||
        currentState is BookErrorMore) {
      final String nextPageUrl;
// Sir in this code the nextpageurl is selected based on the current state
      if (currentState is BookLoaded) {
        nextPageUrl = currentState.nextPageUrl;
        log('nextPageUrl: $nextPageUrl');
      } else if (currentState is BookLoadedMore) {
        nextPageUrl = currentState.nextPageUrl;
        log('nextPageUrl: $nextPageUrl');
      } else {
        nextPageUrl = (currentState as BookErrorMore).nextPageUrl;
        log('nextPageUrl: $nextPageUrl');
      }
// Sir in this code the nextpageurl is selected and passed to fetch the data of the page accroding
      final uri = Uri.parse(nextPageUrl);
      int page = int.parse(uri.queryParameters['page']!);
      emit(BookLoadingMore(books: oldBooks, nextPageUrl: nextPageUrl));

      try {
        if (nextPageUrl.isEmpty) {
          emit(BookNoMore());
        } else {
          final result = await apiService.fetchBook(page);
          oldBooks.addAll(result.book);
          emit(BookLoadedMore(oldBooks, result.next));
        }
      } catch (e) {
        emit(BookErrorMore(e.toString(), oldBooks, nextPageUrl));
      }
    }
  }
}
