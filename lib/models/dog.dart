class Dog {
  String name = '';
  List type = [];
  List images = [];

  Dog({required this.name, required this.type, required this.images});

  Dog.fromJson(String _name, List _type) {
    name = _name;
    type = _type;
    images = [];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = this.id;
  //   data['description'] = this.description;
  //   return data;
  // }
}
