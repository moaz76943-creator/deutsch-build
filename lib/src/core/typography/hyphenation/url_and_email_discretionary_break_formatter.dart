/// Task 1256: Zero-width break injector for long URLs and emails
class UrlBreakFormatter {
  String formatUrl(String url) => url.replaceAll('/', '/\u200B').replaceAll('.', '.\u200B');
}
