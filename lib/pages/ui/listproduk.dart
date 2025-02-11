import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Listproduk extends StatefulWidget {
  const Listproduk({super.key});

  @override
  State<Listproduk> createState() => _ListprodukState();
}

class _ListprodukState extends State<Listproduk> {
  final SupabaseClient supabase = Supabase.instance.client;

  final List<Map<String, dynamic>> produk = [];

  String searchBar = '';

  final _formKey = GlobalKey<FormState>(); // Validasi

  TextEditingController namaProdukController = TextEditingController();
  TextEditingController stokProdukController = TextEditingController();
  TextEditingController hargaProdukController = TextEditingController();

  // Mengambil Data Dari Database Supabase
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

  // Menambahkan Data Ke Dalam Database Supabase
  Future<void> addProduk(String nama, String stok, String harga) async {
    try {
      final existingProduk = await supabase
          .from('produk')
          .select()
          .eq('NamaProduk', nama)
          .maybeSingle();

      if (existingProduk != null) {
        // Jika produk sudah ada, tampilkan pesan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk sudah ada! Gunakan nama lain.')),
          );
        }
        return;
      }

      await supabase.from('produk').insert({
        'NamaProduk': nama,
        'Stok': stok,
        'Harga': harga,
      });

      fetchProduk();

      if (mounted) {
        ElegantNotification.success(
          width: 360,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          title: Text('Success'),
          description: Text('Berhasil Menambahkan Produk'),
          onDismiss: () {},
          onNotificationPressed: () {},
          isDismissable: true,
          dismissDirection: DismissDirection.up,
        ).show(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Menambahkan Produk: $e'),
        ),
      );
    }
  }

  // Mengedit Data Ke Dalam Database Supabase
  Future<void> editProduk(
      int id, String nama, String stok, String harga) async {
    try {
      final existingProduk = await supabase
          .from('produk')
          .select()
          .eq('NamaProduk', nama)
          .neq('ProdukID', id)
          .maybeSingle();

      if (existingProduk != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nama produk sudah digunakan! Pilih nama lain.'),
            ),
          );
        }
        return;
      }

      await supabase.from('produk').update({
        'NamaProduk': nama,
        'Stok': stok,
        'Harga': harga,
      }).eq('ProdukID', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil Mengedit Produk'),
          ),
        );
        fetchProduk();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Mengedit Data: $e'),
        ),
      );
    }
  }

  // Menghapus Data Ke Dalam Database
  Future<void> deleteProduk(int id) async {
    try {
      await supabase.from('produk').delete().eq('ProdukID', id);

      fetchProduk();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil Menghapus Produk'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Menghapus Produk: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    fetchProduk();
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
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: produk.where((p) {
                  return p['NamaProduk'].toLowerCase().contains(searchBar);
                }).length, // Hanya hitung produk yang cocok
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => editProduck(produk[index]),
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Hapus Produk'),
                                        content: Text(
                                            'Apakah Kamu Ingin Menghapus Produk Ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteProduk(produk[index]['Id']);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
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
        onPressed: addProduck,
        child: Icon(Icons.add),
      ),
    );
  }

  // * Alert Dialog Untuk Memunculkan Menambahkan Produk
  void addProduck() {
    showDialog(
        context: context,
        builder: (BuildContext content) {
          return AlertDialog(
            title: Text('Tambahkan Produk'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Produk Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: namaProdukController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.widgets),
                      label: Text('Nama Produk'),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok Produk Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: stokProdukController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.calculate_outlined),
                      label: Text('Stok Produk'),
                      helperText: 'Hanya Bisa Diisi Angka',
                      helperStyle: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga Produk Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: hargaProdukController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.price_change_outlined),
                      label: Text('Harga Produk'),
                      helperText: 'Hanya Bisa Diisi Angka',
                      helperStyle: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final nama = namaProdukController.text;
                            final stok = stokProdukController.text;
                            final harga = hargaProdukController.text;

                            addProduk(nama, stok, harga);
                            Navigator.of(context).pop();

                            namaProdukController.clear();
                            stokProdukController.clear();
                            hargaProdukController.clear();
                          }
                        },
                        child: Text('Simpan'),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  // Alert Dialog Untuk Memunculkan Edit Produk
  void editProduck(Map<String, dynamic> produk) {
    namaProdukController.text = produk['NamaProduk'];
    stokProdukController.text = produk['Stok'].toString();
    hargaProdukController.text = produk['Harga'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Produk'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama Produk Tidak Boleh Kosong'
                      : null,
                  controller: namaProdukController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.widgets),
                    label: Text('Nama Produk'),
                  ),
                ),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Stok Produk Tidak Boleh Kosong'
                      : null,
                  controller: stokProdukController,
                  decoration: InputDecoration(
                    helperText: 'Hanya Bisa Diisi Angka',
                    helperStyle: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.brown,
                    ),
                    icon: Icon(Icons.calculate_outlined),
                    label: Text('Stok Produk'),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Harga Produk Tidak Boleh Kosong'
                      : null,
                  controller: hargaProdukController,
                  decoration: InputDecoration(
                    helperText: 'Hanya Bisa Diisi Angka',
                    helperStyle: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.brown,
                    ),
                    icon: Icon(Icons.price_change_outlined),
                    label: Text('Harga Produk'),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          editProduk(
                            produk['Id'],
                            namaProdukController.text,
                            stokProdukController.text,
                            hargaProdukController.text,
                          );
                          fetchProduk();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Simpan'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
