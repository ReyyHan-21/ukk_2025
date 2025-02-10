import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final SupabaseClient supabase = Supabase.instance.client;

  String searchBar = '';
  String? selectedPelanggan;

  final List<Map<String, dynamic>> produk = [];

  final List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> pelanggan = [];

  // Mengambil data Pelanggan Dari Supabase
  Future<void> fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      if (mounted) {
        setState(() {
          pelanggan = (response as List<dynamic>).map((pelanggan) {
            return {
              'id': pelanggan['PelangganID'],
              'nama': pelanggan['NamaPelanggan'],
            };
          }).toList();
        });
      }
    } catch (e) {
      _showError(e);
    }
  }

  // Mengambil Data Dari Tabel Produk Supabase
  Future<void> fetchProduk() async {
    try {
      final response = await supabase.from('produk').select();

      if (mounted) {
        setState(() {
          produk.clear();
          produk.addAll((response as List<dynamic>).map((produk) {
            return {
              'Id': produk['ProdukID'],
              'NamaProduk': produk['NamaProduk'],
              'Stok': produk['Stok'],
              'Harga': produk['Harga'],
            };
          }).toList());
        });
      }

      print(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil produk: $e')),
        );
      }
    }
  }

  // * Menambahkan item kedalam keranjang dengan jumlah
  void addToCart(Map<String, dynamic> item) {
    setState(() {
      int productIndex = cart.indexWhere((prod) => prod['Id'] == item['Id']);
      if (productIndex == -1) {
        cart.add({...item, 'quantity': 1});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${item['NamaProduk']} telah ditambahkan ke keranjang!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${item['NamaProduk']} sudah ada di keranjang!')),
        );
      }
    });
  }

// digunakan untuk menambahkan jumlah product yang ada di keranjang
  void updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        cart.removeAt(index); // Menghapus Produk Jika Nilai 1 Dikurangi
      } else {
        int availableStock = cart[index]['Stok'];
        if (quantity <= availableStock) {
          cart[index]['quantity'] = quantity;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Jumlah yang tersedia hanya $availableStock')),
          );
        }
      }
    });
  }

  // Digunakan Untuk Membuat Pesan
  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
      ),
    );
  }

  // menyimpan transaksi ke Supabase
  Future<void> submitTransaction() async {
    if (selectedPelanggan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu!')),
      );
      return;
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }

    try {
      final String tanggal = DateTime.now().toIso8601String();
      final int totalHarga = getTotalBelanja(); // Pastikan total harga benar

      // Debugging untuk memastikan nilai yang dikirim
      print('🛒 Transaksi dimulai...');
      print('🛒 PelangganID: $selectedPelanggan');
      print('🛒 TotalHarga: $totalHarga');
      print('🛒 Tanggal: $tanggal');

      // Simpan transaksi ke tabel 'penjualan'
      final response = await supabase.from('penjualan').insert({
        'PelangganID': selectedPelanggan,
        'TotalHarga': totalHarga,
        'TanggalPenjualan': tanggal,
      }).select(); // Menggunakan select() agar mendapatkan response balik

      if (response.isEmpty) {
        throw Exception('Gagal menyimpan transaksi. Response kosong.');
      }

      print('✅ Transaksi berhasil!');

      // 🔹 Pastikan stok diperbarui setelah transaksi sukses
      await updateStock();

      // 🔹 Reset keranjang setelah stok diperbarui
      setState(() {
        cart.clear();
      });

      // 🔹 Notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil! Stok telah diperbarui.')),
      );

      // 🔹 Tutup modal
      Navigator.of(context).pop();
    } catch (e) {
      print('❌ Gagal menyimpan transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
      );
    }
  }

  //  mengurangi stok produk setelah Membeli
  Future<void> updateStock() async {
    try {
      for (var item in cart) {
        final int currentStock = item['Stok'] ?? 0; // Pastikan stok tidak null
        final num newStock = currentStock -
            (item['quantity'] ?? 0); // Pastikan quantity tidak null

        if (newStock < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Stok ${item['NamaProduk']} tidak mencukupi!')),
          );
          return;
        }

        // Debug log untuk memastikan nilai yang dikirim ke database
        print(
            'Mengupdate stok: ProdukID = ${item['Id']}, Stok Baru = $newStock');

        // Update stok di database Supabase
        final response = await supabase
            .from('produk')
            .update({'Stok': newStock}).match({'ProdukID': item['Id']});

        if (response.error != null) {
          print('❌ Error saat update stok: ${response.error!.message}');
          throw response.error!;
        }

        print('✅ Stok produk ${item['NamaProduk']} berhasil diperbarui!');
      }
    } catch (e) {
      print('❌ Gagal memperbarui stok: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui stok: $e')),
      );
    }
  }

  // Total Belanjan
  int getTotalBelanja() {
    return cart.fold(0, (total, item) {
      int harga = item['Harga'];
      int quantity = item['quantity'];
      return total + (harga * quantity);
    });
  }

  @override
  void initState() {
    fetchProduk();
    fetchPelanggan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFBB784C),
              ),
            ),
            RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Di ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: 'Coffee Shop ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF6D0D),
                    ),
                  ),
                  TextSpan(
                    text: 'Kami',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari Produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchBar =
                      value.toLowerCase(); // Simpan query dalam huruf kecil
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                // * Search Bar
                itemCount: produk.where((p) {
                  return p['NamaProduk'].toLowerCase().contains(searchBar);
                }).length,
                itemBuilder: (context, index) {
                  final filteredProduk = produk.where((p) {
                    return p['NamaProduk'].toLowerCase().contains(searchBar);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.coffee),
                        title: Text(
                          filteredProduk[index]['NamaProduk'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stok: ${filteredProduk[index]['Stok']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Harga: Rp ${filteredProduk[index]['Harga']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () => addToCart(filteredProduk[index]),
                          icon: Icon(Icons.add_shopping_cart_outlined),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Color(0xFFBB784C),
        foregroundColor: Colors.white,
        onPressed: cartTransaction,
        child: Icon(Icons.shopping_cart),
      ),
    );
  }

// Menampilkan Keranjang Belanja
  void cartTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keranjang Belanja',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),

                  // Dropdown Pilih Pelanggan
                  DropdownButtonFormField<String>(
                    value: selectedPelanggan,
                    decoration: InputDecoration(
                      labelText: 'Pilih Pelanggan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: pelanggan.map((pelanggan) {
                      return DropdownMenuItem(
                        value: pelanggan['id'].toString(),
                        child: Text(pelanggan['nama']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPelanggan = value;
                      });
                    },
                  ),

                  SizedBox(height: 10),

                  // List Keranjang
                  Expanded(
                    child: cart.isEmpty
                        ? Center(
                            child: Text(
                              'Keranjang masih kosong!',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            itemCount: cart.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(cart[index]['NamaProduk']),
                                subtitle: Text(
                                  'Jumlah: ${cart[index]['quantity']} | Total: Rp ${cart[index]['Harga'] * cart[index]['quantity']}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          updateQuantity(index,
                                              cart[index]['quantity'] - 1);
                                        });
                                      },
                                    ),
                                    Text('${cart[index]['quantity']}'),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        setState(
                                          () {
                                            updateQuantity(index,
                                                cart[index]['quantity'] + 1);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  SizedBox(height: 10),

                  // * Jumlah Penjualan
                  Text(
                    'Total Belanja: Rp ${getTotalBelanja()}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  // * Tombol Batal dan Beli
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          submitTransaction();
                          if (selectedPelanggan == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Silakan pilih pelanggan terlebih dahulu!',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Pembelian berhasil!',
                                ),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Beli'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
