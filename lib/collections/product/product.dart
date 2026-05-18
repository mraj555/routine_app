import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Product({
    this.id,
    this.title,
    this.image,
    this.description,
    this.category,
    this.price,
    this.rating,
  });

  Id? id;
  String? title;
  double? price;
  String? description;
  String? category;
  String? image;
  Rating? rating;

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "description": description,
    "image": image,
    "category": category,
    "rating": rating!.toJson(),
  };
}

@embedded
class Rating {
  Rating({this.rate, this.count});

  double? rate;
  int? count;

  Map<String, dynamic> toJson() => {"rate": rate, "count": count};
}
