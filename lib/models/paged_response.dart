class PagedResponse<T> {
  PagedResponse({required this.page, required this.totalPages, required this.totalResults, required this.results});
  final int page;
  final int totalPages;
  final int totalResults;
  final List<T> results;
}
