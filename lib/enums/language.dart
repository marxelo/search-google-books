enum Language {
  pt(fullName: 'Português'),
  es(fullName: 'Espanhol'),
  en(fullName: 'Inglês'),
  all(fullName: 'Todos');

  const Language({
    required this.fullName,
  });

  final String fullName;
}
