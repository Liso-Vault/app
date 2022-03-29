class LisoField {
  // final LisoFieldType type;
  final bool obscured; // obscure field by default
  final bool protected; // obscured + require's vault password to reveal
  final List<String> tags;

  LisoField({
    // this.type = LisoFieldType.text,
    this.obscured = false,
    this.protected = false,
    this.tags = const [],
  });

  factory LisoField.fromJson(Map<String, dynamic> json) => LisoField(
        obscured: json["obscured"],
        protected: json["protected"],
        tags: json["tags"],
      );

  Map<String, dynamic> toJson() {
    return {
      "obscured": obscured,
      "protected": protected,
      "tags": tags,
    };
  }
}

// enum LisoFieldType {
//   section,
//   text,
//   textArea,
//   address,
//   gender,
//   date,
//   time,
//   datetime,
//   country,
//   phone,
//   email,
//   url,
//   password,
// }

class LisoFieldSection extends LisoField {
  final String value;
  LisoFieldSection({this.value = ''});
}

class LisoFieldText extends LisoField {
  final String value;
  LisoFieldText({this.value = ''});
}

class LisoFieldTextArea extends LisoField {
  final String value;
  LisoFieldTextArea({this.value = ''});
}

class LisoFieldAddress extends LisoField {
  final String street1;
  final String street2;
  final String city; // or district
  final String state; // or province
  final String zip;
  final String country;

  LisoFieldAddress({
    this.street1 = '',
    this.street2 = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.country = '',
  });
}
