// ignore_for_file: use_build_context_synchronously

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/helper/notification.dart';

import '../component/pdf.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final SupabaseClient supabase = Supabase.instance.client;

  String searchBar = '';
  String? selectedPelanggan;
  bool applyDiscount = false;

  final List<Map<String, dynamic>> produk = [];

  final List<Map<String, dynamic>> cart = [];
  final List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> pelanggan = [];

  final double discountRate = 0.10;

  // * Mengambil data Pelanggan Dari Supabase
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
      NotificationHelper.showError(context, e);
    }
  }

  // * Mengambil data user Dari Supabase
  Future<void> fetchUser() async {
    try {
      final response = await supabase.from('user').select();

      setState(() {
        if (mounted) {
          user.clear();
          user.addAll((response as List<dynamic>).map((user) {
            return {
              'id': user['id'],
              'username': user['username'],
              'password': user['password'],
              'role': user['role'],
            };
          }).toList());
        }
      });

      // Digunakan Untuk mendebug hasil dari response
      if (kDebugMode) {
        print(user.map((user) => user['username']).toList());
      }
    } catch (e) {
      NotificationHelper.showError(context, e);
    }
  }

  // * Mengambil Data Dari Tabel Produk Supabase
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

      if (kDebugMode) {
        print(produk.map((item) => item['NamaProduk']).toList());
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Gagal Mengambil Produk: $e');
      }
    }
  }

  // * Menambahkan item kedalam keranjang dengan jumlah
  void addToCart(Map<String, dynamic> item) {
    setState(() {
      int productIndex = cart.indexWhere((prod) => prod['Id'] == item['Id']);
      if (productIndex == -1) {
        cart.add({...item, 'quantity': 1});
        NotificationHelper.showInfo(
            context, '${item['NamaProduk']} telah ditambahkan di keranjang');
      } else {
        NotificationHelper.showErrorMessage(
            context, '${item['NamaProduk']} sudah ada di keranjang!');
      }
    });
  }

// * digunakan untuk menambahkan jumlah product yang ada di keranjang
  void updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        cart.removeAt(index); // Menghapus Produk Jika Nilai 1 Dikurangi
      } else {
        int availableStock = cart[index]['Stok'];
        if (quantity <= availableStock) {
          cart[index]['quantity'] = quantity;
        } else {
          NotificationHelper.showInfo(
              context, 'Stok Yang Tersedia Hanya: $availableStock');
        }
      }
    });
  }

  // menyimpan transaksi ke Supabase
  Future<void> submitTransaction() async {
    if (selectedPelanggan == null) {
      NotificationHelper.showInfo(
          context, 'Silahkan Pilih Pelanggan Terlebih Dahulu');
      return;
    }

    if (cart.isEmpty) {
      NotificationHelper.showInfo(context, 'Keranjang Masih Kosong!');
      return;
    }

    try {
      final String tanggal =
          DateTime.now().toIso8601String(); // Format Untuk Tanggal
      final int totalHarga = getTotalBelanja();

      final response = await supabase.from('penjualan').insert({
        'PelangganID': selectedPelanggan,
        'TotalHarga': totalHarga,
        'TanggalPenjualan': tanggal,
      }).select();

      if (response.isEmpty) {
        throw Exception('Gagal menyimpan transaksi');
      }

      // Simpan detail transaksi ke tabel 'detail_penjualan'
      for (var item in cart) {
        final int penjualanID = response[0]['PenjualanID'];
        final int subTotal = item['Harga'] * item['quantity'];

        await supabase.from('detail_penjualan').insert({
          'PenjualanID': penjualanID,
          'ProdukID': item['Id'],
          'JumlahProduk': item['quantity'],
          'SubTotal': subTotal,
        });
      }

      // Perbarui stok produk
      await updateStock();
      await fetchProduk();

      List<Map<String, dynamic>> transaksi = List.from(cart);

      // Tampilkan dialog konfirmasi
      if (mounted) {
        showDetailTransaksiDialog(context, transaksi, totalHarga, tanggal,
            getNamaPelanggan(selectedPelanggan));
      }

      // Reset keranjang setelah sukses
      setState(() {
        cart.clear();
        selectedPelanggan = null;
      });

      print(Text('Transaksi Berhasil'));
    } catch (e) {
      NotificationHelper.showError(context, e);
    }
  }

  //  mengurangi stok produk setelah Membeli
  Future<void> updateStock() async {
    try {
      for (var item in cart) {
        final int currentStock = item['Stok'] ?? 0;
        final num newStock = currentStock - (item['quantity'] ?? 0);

        if (newStock < 0) {
          NotificationHelper.showInfo(
              context, 'Stok ${item['NamaProduk']} tidak mencukupi!');
          return;
        }

        print(
            'Mengupdate stok: ProdukID = ${item['Id']}, Stok Baru = $newStock');

        await supabase
            .from('produk')
            .update({'Stok': newStock}).match({'ProdukID': item['Id']});

        print('✅ Stok produk ${item['NamaProduk']} berhasil diperbarui!');
      }
    } catch (e) {
      print('❌ Gagal memperbarui stok: $e');
      NotificationHelper.showError(context, e);
    }
  }

  // Total Belanjan
  int getTotalBelanja() {
    int total = cart.fold(
        0,
        (sum, item) =>
            sum + (item['Harga'] as int) * (item['quantity'] as int));

    if (applyDiscount) {
      total = (total * (1 - discountRate)).toInt();
    }
    return total;
  }

  // Discount
  double getDiscountedPrice(Map<String, dynamic> product) {
    double hargaAsli = product['Harga'] * product['quantity'];
    double diskon = (product['quantity'] > 4) ? (product['discount'] ?? 0) : 0;
    return hargaAsli - (hargaAsli * (diskon / 100));
  }

  // Memanggil Nama Pelanggan
  String getNamaPelanggan(String? id) {
    if (id == null) return 'Tidak dipilih';

    final pelangganData = pelanggan.firstWhere(
      (pelanggan) => pelanggan['id'].toString() == id,
      orElse: () => {'nama': 'Tidak ditemukan'},
    );

    return pelangganData['nama'];
  }

  @override
  void initState() {
    fetchProduk();
    fetchUser();
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
                    text: (user.isNotEmpty
                        ? user[0]['username'] ?? 'User'
                        : 'Loading...'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF6D0D),
                    ),
                  ),
                  TextSpan(text: ' '),
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
                        leading: Icon(
                          Icons.coffee,
                          color: Color(0xFFBB784C),
                        ),
                        title: Text(
                          filteredProduk[index]['NamaProduk'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Stok: ${filteredProduk[index]['Stok'] == 0 ? 'Habis' : filteredProduk[index]['Stok']} || Harga: Rp ${filteredProduk[index]['Harga']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: cart.contains(filteredProduk[index])
                            ? Icon(
                                Icons.check,
                                color: Colors.green,
                              ) // Produk sudah ada di cart
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    addToCart(filteredProduk[index]);
                                  });
                                },
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
                        value: pelanggan['id'].toString(), // ID pelanggan
                        child: Text(pelanggan['nama']), // Nama pelanggan
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPelanggan = value;
                        applyDiscount = value != null;
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jumlah: ${cart[index]['quantity']}'),
                                    if (applyDiscount &&
                                        cart[index]['quantity'] > 4 &&
                                        cart[index]['discount'] != null) ...[
                                      Text(
                                        'Rp ${cart[index]['Harga'] * cart[index]['quantity']}',
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${getDiscountedPrice(cart[index])}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'Total: Rp ${cart[index]['Harga'] * cart[index]['quantity']}',
                                      ),
                                    ],
                                  ],
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
                                        setState(() {
                                          updateQuantity(index,
                                              cart[index]['quantity'] + 1);
                                        });
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
                            NotificationHelper.showInfo(context,
                                'Silahkan Pilih Pelanggan Terlebih Dahulu');
                          } else {
                            NotificationHelper.showSuccess(
                                context, 'Pembelian Berhasil');
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

// Menampilkan Dialog Pemberitahuan Selesai Transaksi
  void showDetailTransaksiDialog(
      BuildContext context,
      List<Map<String, dynamic>> transaksi,
      int totalHarga,
      String tanggalPembelian,
      String namaPelanggan) {
    // Sekarang menerima nama, bukan ID
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Detail Transaksi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pelanggan: $namaPelanggan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tanggal: $tanggalPembelian',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Produk yang dibeli:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: transaksi.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['NamaProduk']),
                      subtitle: Text(
                          'Jumlah: ${item['quantity']} | Harga: Rp ${item['Harga']}'),
                      trailing: Text(
                          'Subtotal: Rp ${item['Harga'] * item['quantity']}'),
                    );
                  }).toList(),
                ),
                Divider(),
                Text(
                  'Total Belanja: Rp $totalHarga',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                generateInvoicePDF(context, namaPelanggan, tanggalPembelian,
                    transaksi, totalHarga);
              },
              child: Text('Cetak PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
