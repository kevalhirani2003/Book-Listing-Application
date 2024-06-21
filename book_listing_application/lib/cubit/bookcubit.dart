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

  BookErrorMore(this.message);
}

class BookNoMore extends BookState {}

class BookCubit extends Cubit<BookState> {
  final ApiService apiService;
  late int page = 1;
  List<Book> oldBooks = [];

  BookCubit(this.apiService) : super(BookInitial());

  void fetchBooks() async {
    emit(BookLoading());
    try {
      final result = await apiService.fetchBook(page);
      oldBooks = result.book;
      emit(BookLoaded(result.book, result.next));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  void fetchMoreBooks() async {
    final currentState = state;
    log('currentState: $currentState');
    if (currentState is BookLoaded || currentState is BookLoadedMore) {
      final nextPageUrl = (currentState is BookLoaded)
          ? currentState.nextPageUrl
          : (currentState as BookLoadedMore).nextPageUrl;
      emit(BookLoadingMore(books: oldBooks, nextPageUrl: nextPageUrl));

      try {
        log('nextPageUrl: $nextPageUrl');
        if (nextPageUrl.isEmpty) {
          emit(BookNoMore());
        } else {
          page++;
          final result = await apiService.fetchBook(page);
          oldBooks.addAll(result.book);
          emit(BookLoadedMore(oldBooks, result.next));
        }
      } catch (e) {
        emit(BookErrorMore(e.toString()));
      }
    }
  }
}
