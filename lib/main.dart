import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(),
        useMaterial3: false,
      ),
      home: BlocProvider(
        create: (context) => ProductBloc()..add(FetchProducts()),
        child: MyHomePage(title: "Products"),
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['title'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['thumbnail'],
    );
  }
}

// Bloc Event
abstract class ProductEvent {}

class FetchProducts extends ProductEvent {}

// Bloc State
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String error;
  ProductError(this.error);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final response =
          await http.get(Uri.parse('https://dummyjson.com/products'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body)['products'] as List;
        final productList =
            jsonResponse.map((product) => Product.fromJson(product)).toList();
        emit(ProductLoaded(productList));
        print("Emitted");
      } else {
        emit(ProductError('Error loading products'));
        ;
      }
    } catch (e) {
      emit(ProductError('Error'));
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  // Future<List<Product>> fetchProducts() async {
  //   final response =
  //       await http.get(Uri.parse('https://dummyjson.com/products'));
  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body)['products'] as List;
  //     return jsonResponse.map((product) => Product.fromJson(product)).toList();
  //   } else {
  //     throw Exception('Error loading products');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
          if (state is ProductLoading) {
            return Text("Loading products");
          } else if (state is ProductLoaded) {
            return Center(
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  var product = state.products[index];
                  return ListTile(
                    title: Text(product.name ?? 'No Name'),
                    subtitle: Text(product.description ?? 'No Description'),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(product.imageUrl!),
                    ),
                  );
                },
              ),
            );
          } else if (state is ProductError) {
            return const Text("Error loading products");
          }
          return const Text("No products found");
        })
        // body: Center(
        //   child: FutureBuilder<List<Product>>(
        //     future: fetchProducts(),
        //     builder: (context, snap) {
        //       if (snap.connectionState == ConnectionState.waiting) {
        //         return const CircularProgressIndicator();
        //       } else if (snap.hasError) {
        //         return const Text("Error loading products");
        //       } else if (snap.hasData) {
        //         return ListView.builder(
        //           itemCount: snap.data!.length,
        //           itemBuilder: (context, index) {
        //             var product = snap.data![index];
        //             return ListTile(
        //               title: Text(product.name ?? 'No Name'),
        //               subtitle: Text(product.description ?? 'No Description'),
        //               leading: CircleAvatar(
        //                 backgroundImage: NetworkImage(product.imageUrl!),
        //               ),
        //             );
        //           },
        //         );
        //       }
        //       return const Text("No products found");
        //     },
        //   ),
        // ),
        );
  }
}
