import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    // ... (createOrUpdate function remains the same)
  }

  Future<void> _deleteProduct(String productId) async {
    // ... (deleteProduct function remains the same)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Price'),
                    onChanged: (value) =>
                        _minPrice = double.tryParse(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Price'),
                    onChanged: (value) =>
                        _maxPrice = double.tryParse(value),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Filter'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = null;
                      _maxPrice = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _products.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  List<DocumentSnapshot> products = streamSnapshot.data!.docs
                      .where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    final price = doc['price'];

                    final nameMatch =
                        _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
                    final priceMatch = (_minPrice == null || price >= _minPrice!) &&
                        (_maxPrice == null || price <= _maxPrice!);

                    return nameMatch && priceMatch;
                  }).toList();

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = products[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']),
                          subtitle: Text(documentSnapshot['price'].toString()),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _createOrUpdate(documentSnapshot),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteProduct(documentSnapshot.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}