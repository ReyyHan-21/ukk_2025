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
  final List<Map<String, dynamic>> produk = [];

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
            SizedBox(
              height: 10,
            ),
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
                        trailing: IconButton(
                          onPressed: () {},
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
        onPressed: () {},
        child: Icon(Icons.chat_rounded),
      ),
    );
  }
}
