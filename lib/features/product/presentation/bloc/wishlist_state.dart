part of 'wishlist_cubit.dart';

@immutable
abstract class WishlistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  WishlistInitial();
}

// WISHLIST
class WishlistLoading extends WishlistState {
  final String? message;
  WishlistLoading({this.message = "Loading..."});
  @override
  List<Object?> get props => [message];
}

class WishlistLoaded extends WishlistState {
  final List<Product>? products;
  WishlistLoaded({this.products});
  @override
  List<Object?> get props => [products];
}

class ClearWishlist extends WishlistState {
  final String? message;
  ClearWishlist({this.message = "Clear wishlist..."});
  @override
  List<Object?> get props => [message];
}

class RemoveFromWishlist extends WishlistState {
  final String? message;
  RemoveFromWishlist({this.message});
  @override
  List<Object?> get props => [message];
}

class WishlistError extends WishlistState {
  final String message;
  WishlistError({this.message = "Something wrong..."});
  @override
  List<Object?> get props => [message];
}
