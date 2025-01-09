import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Depo Takip Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // SharedPreferences'ten kaydedilen bilgileri al
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedUsername = prefs.getString('username') ?? 'admin';
      String? savedPassword = prefs.getString('password') ?? '1234';

      if (username == savedUsername && password == savedPassword) {
        await prefs.setString('username', username);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: username)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı adı veya şifre hatalı!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Depo Takip Sistemi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kullanıcı adını giriniz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifreyi giriniz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Giriş Yap'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _products = [
    {'name': 'Çekiç', 'quantity': 10},
    {'name': 'Matkap', 'quantity': 5},
    {'name': 'Tornavida Seti', 'quantity': 20},
  ];

  void _removeProduct(int index, int removeQuantity) {
    setState(() {
      if (_products[index]['quantity'] > removeQuantity) {
        _products[index]['quantity'] -= removeQuantity;
      } else {
        _products.removeAt(index);
      }
    });
  }

  void _addProduct(String name, int quantity) {
    setState(() {
      bool exists = false;
      for (var product in _products) {
        if (product['name'] == name) {
          product['quantity'] += quantity;
          exists = true;
          break;
        }
      }
      if (!exists) {
        _products.add({'name': name, 'quantity': quantity});
      }
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          username: widget.username,
          onUpdateProfile: (newUsername, newPassword) {
            setState(() {
              // Update username locally if needed
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Depo Yönetimi'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Ürün Listesi'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: _products.map((product) {
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text('Adet: ${product['quantity']}'),
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Kapat'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.inventory),
                    title: Text(product['name']),
                    subtitle: Text('Adet: ${product['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.orange),
                          onPressed: () async {
                            final result = await showDialog<int>(
                              context: context,
                              builder: (context) => RemoveProductDialog(
                                maxQuantity: product['quantity'],
                              ),
                            );
                            if (result != null) {
                              _removeProduct(index, result);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProduct(index, product['quantity']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(),
                    ),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    _addProduct(result['name'], result['quantity']);
                  }
                },
                child: Text('Ürün Ekle'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void _submitProduct() {
    final String name = _nameController.text;
    final int? quantity = int.tryParse(_quantityController.text);

    if (name.isNotEmpty && quantity != null) {
      Navigator.pop(context, {'name': name, 'quantity': quantity});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen geçerli bir ad ve adet giriniz!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ürün Ekle')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Ürün Adı'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Adet'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProduct,
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

class RemoveProductDialog extends StatelessWidget {
  final int maxQuantity;

  RemoveProductDialog({required this.maxQuantity});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _quantityController = TextEditingController();

    return AlertDialog(
      title: Text('Ürün Çıkar'),
      content: TextField(
        controller: _quantityController,
        decoration: InputDecoration(labelText: 'Çıkarılacak Adet'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final int? quantity = int.tryParse(_quantityController.text);
            if (quantity != null && quantity > 0 && quantity <= maxQuantity) {
              Navigator.pop(context, quantity);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Geçersiz miktar!')),
              );
            }
          },
          child: Text('Onayla'),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String username;
  final Function(String, String) onUpdateProfile;

  ProfilePage({required this.username, required this.onUpdateProfile});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController(text: username);
    final TextEditingController _passwordController = TextEditingController();

    Future<void> _updateProfile() async {
      final newUsername = _usernameController.text;
      final newPassword = _passwordController.text;

      if (newUsername.isNotEmpty && newPassword.isNotEmpty) {
        // SharedPreferences ile yeni bilgileri kaydet
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', newUsername);
        await prefs.setString('password', newPassword);

        // Geri bildirim mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellendi!')),
        );

        // Ana ekrana dönerken yeni bilgileri güncelle
        onUpdateProfile(newUsername, newPassword);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Yeni Kullanıcı Adı'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Yeni Şifre'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
