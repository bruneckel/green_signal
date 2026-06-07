class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.passwordHash,
  });

  final String name;
  final String email;
  final String address;
  final String phone;
  final String passwordHash;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'address': address,
        'phone': phone,
        'passwordHash': passwordHash,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      passwordHash: json['passwordHash'] as String,
    );
  }
}
