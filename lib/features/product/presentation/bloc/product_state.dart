part of 'product_cubit.dart';

@immutable
abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  ProductInitial();
}

class ProductInitialized extends ProductState {}

// PRODUCTS
class ProductLoading extends ProductState {
  final String? message;
  ProductLoading({this.message = "Loading..."});
  @override
  List<Object?> get props => [message];
}

class ProductLoaded extends ProductState {
  final List<Product>? products;
  ProductLoaded({this.products});
  @override
  List<Object?> get props => [products];
}

class ProductDetailLoaded extends ProductState {
  final Product? product;
  ProductDetailLoaded({this.product});
  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;
  ProductError({this.message = "Something wrong..."});
  @override
  List<Object?> get props => [message];
}

class WishlistAdded extends ProductState {
  final Product? product;
  WishlistAdded({this.product});
  @override
  List<Object?> get props => [product];
}

class WishlistRemoved extends ProductState {
  final Product? product;
  WishlistRemoved({this.product});
  @override
  List<Object?> get props => [product];
}
