class Member {
  Member({
    required this.handle,
  });

  final String? handle;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      handle: json["handle"],
    );
  }

  Map<String, dynamic> toJson() => {
        "handle": handle,
      };
}
