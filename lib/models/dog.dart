class Dog {
  String name = '';
  List type = [];
  String img = '';

  Dog({required this.name, required this.type, required this.img});

  Dog.fromJson(String _name, List _type) {
    name = _name;
    type = _type;
    img = '';
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = this.id;
  //   data['description'] = this.description;
  //   return data;
  // }
}
