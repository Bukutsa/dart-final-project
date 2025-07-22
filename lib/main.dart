import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingTrackerApp());
}

class ShoppingTrackerApp extends StatelessWidget {
  const ShoppingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShoppingItem {
  final String name;
  final double quantity;
  final String unit;

  ShoppingItem({required this.name, required this.quantity, required this.unit});
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/1170/1170576.png'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Welcome to Blenka Shopping Tracker!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_ios),
                    label: const Text('Get Started'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainShoppingScreen()),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainShoppingScreen extends StatefulWidget {
  const MainShoppingScreen({super.key});

  @override
  State<MainShoppingScreen> createState() => _MainShoppingScreenState();
}

class _MainShoppingScreenState extends State<MainShoppingScreen> {
  int _currentIndex = 0;

  final Map<String, List<ShoppingItem>> categorizedItems = {
    'Vegetables and Fruits': [],
    'Cereals': [],
    'Dairies': [],
    'Beverages': [],
    'Meat': [],
    'Other': [],
  };

  final Map<String, double> consumption = {};

  final Map<String, List<String>> unitOptions = {
    'Vegetables and Fruits': ['pcs', 'kg'],
    'Cereals': ['kg', 'g'],
    'Dairies': ['litres', 'ml'],
    'Beverages': ['litres', 'ml', 'bottles'],
    'Meat': ['kg', 'g'],
    'Other': ['pcs', 'kg', 'g', 'litres', 'ml', 'bottles'],
  };

  void addItem(String category, ShoppingItem item) {
    setState(() {
      categorizedItems[category]!.add(item);
    });
  }

  void updateConsumption(String key, double value) {
    setState(() {
      consumption[key] = value;
    });
  }

  void deleteConsumption(String key) {
    setState(() {
      consumption.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      CategorizedShoppingWidget(
        categorizedItems: categorizedItems,
        unitOptions: unitOptions,
        onAddItem: addItem,
      ),
      UsageScreen(
        categorizedItems: categorizedItems,
        consumption: consumption,
        onUpdateConsumption: updateConsumption,
        onDeleteConsumption: deleteConsumption,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Tracker')),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Usage'),
        ],
      ),
    );
  }
}

class CategorizedShoppingWidget extends StatelessWidget {
  final Map<String, List<ShoppingItem>> categorizedItems;
  final Map<String, List<String>> unitOptions;
  final Function(String category, ShoppingItem item) onAddItem;

  const CategorizedShoppingWidget({
    super.key,
    required this.categorizedItems,
    required this.unitOptions,
    required this.onAddItem,
  });

  void _showAddItemDialog(BuildContext context, String category) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String selectedUnit = unitOptions[category]!.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Add item to $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item name'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              DropdownButton<String>(
                value: selectedUnit,
                items: unitOptions[category]!
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setStateDialog(() => selectedUnit = value!);
                },
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final name = nameController.text.trim();
                final quantity =
                    double.tryParse(quantityController.text.trim()) ?? 0;
                if (name.isNotEmpty && quantity > 0) {
                  onAddItem(
                    category,
                    ShoppingItem(name: name, quantity: quantity, unit: selectedUnit),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      quantityController.dispose();
    });
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        title:
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.add),
        onTap: () => _showAddItemDialog(context, category),
      ),
    );
  }

  Widget _buildItemList(String category, List<ShoppingItem> items) {
    if (items.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...items.map(
            (item) => ListTile(
              key: ValueKey(item.name),
              leading: const Icon(Icons.shopping_cart),
              title: Text(item.name),
              subtitle: Text('${item.quantity} ${item.unit}'),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select a category to add items:',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ...categorizedItems.keys
            .map((category) => _buildCategoryCard(context, category))
            .toList(),
        const Divider(thickness: 1),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Your Shopping List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...categorizedItems.entries
            .map((e) => _buildItemList(e.key, e.value))
            .toList(),
      ],
    );
  }
}

class UsageScreen extends StatelessWidget {
  final Map<String, List<ShoppingItem>> categorizedItems;
  final Map<String, double> consumption;
  final Function(String key, double value) onUpdateConsumption;
  final Function(String key) onDeleteConsumption;

  const UsageScreen({
    super.key,
    required this.categorizedItems,
    required this.consumption,
    required this.onUpdateConsumption,
    required this.onDeleteConsumption,
  });

  void _showEditUsageDialog(
      BuildContext context, String key, double currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit usage for $key'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Consumed quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text.trim());
              if (newValue != null && newValue >= 0) {
                onUpdateConsumption(key, newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> usageItems = [];

    categorizedItems.forEach((category, items) {
      if (items.isEmpty) return;

      usageItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            category,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
      );

      for (var item in items) {
        final key = '$category - ${item.name}';
        final consumed = consumption[key] ?? 0.0;

        usageItems.add(
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                  'Bought: ${item.quantity} ${item.unit}\nConsumed: $consumed ${item.unit}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    onPressed: () => _showEditUsageDialog(context, key, consumed),
                  ),
                  if (consumed > 0)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDeleteConsumption(key),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    });

    if (usageItems.isEmpty) {
      return const Center(
        child: Text(
          'No items added yet.\nAdd some items in the Shopping tab.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(children: usageItems);
  }
}
