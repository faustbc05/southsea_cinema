class UserSettings {
  final String name;
  final String address;
  final String email;
  final bool receiveNewsletter;

  const UserSettings(
      {required this.name,
      required this.address,
      required this.email,
      required this.receiveNewsletter});
}
