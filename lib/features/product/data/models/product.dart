import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String? name;
  @HiveField(1)
  final String? description;
  @HiveField(2)
  final String? price;
  @HiveField(3)
  final String? image;
  @HiveField(4)
  final int? id;
  @HiveField(5)
  bool? isWishlist;

  Product({
    this.name,
    this.description,
    this.price,
    this.image,
    this.id,
    this.isWishlist = false,
  });

  @override
  List<Object?> get props => [name, description, price, image, id, isWishlist];

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        id: int.parse(json["id"]),
        isWishlist: json["isWishlist"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "id": id,
        "isWishlist": isWishlist ?? false,
      }..removeWhere((k, v) => v == null);
}
