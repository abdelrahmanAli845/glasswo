import 'package:flutter/material.dart';
import 'package:glass_wo/screens/product_screen/product_form.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../model_screen/model_screen.dart';
import '../shapeScreen/shape_screen.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("المنتجات")),
      body: ListView.builder(
        itemCount: provider.products.length,
        cacheExtent: 500,

        itemBuilder: (_, i) {
          final product = provider.products[i];

          return Card(
            child: ListTile(
              title: Text(product.name),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModelsScreen(product: product),
                  ),
                );
              },

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      showProductForm(context, product: product);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.delete(product.id);
                    },
                  ),
                ],
              ),
            ),
          );        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductForm(context),
        child: Icon(Icons.add),
      ),
    );
  }
}