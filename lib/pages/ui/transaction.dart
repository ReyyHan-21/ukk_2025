import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  String searchBar = '';
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> detail_penjualan = [];

  // Mengambil Data Transaksi
  Future<void> fetchDetail() async {
    try {
      final response = await supabase
          .from('penjualan')
          .select(
              'PenjualanID, TanggalPenjualan, TotalHarga, pelanggan(NamaPelanggan), detail_penjualan(JumlahProduk, SubTotal, produk(NamaProduk, Harga))')
          .order('TanggalPenjualan', ascending: false);

      if (mounted) {
        setState(() {
          detail_penjualan = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      _showError(e);
    }
  }

  // Fungsi Hapus Transaksi
  Future<void> deleteTransaction(int id) async {
    try {
      await supabase.from('penjualan').delete().match({'PenjualanID': id});
      fetchDetail(); // Refresh data setelah hapus
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus')),
      );
    } catch (e) {
      _showError(e);
    }
  }

  // Tampilkan Dialog Konfirmasi Hapus
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteTransaction(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }

  @override
  void initState() {
    fetchDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Cari Transaksi.....',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchBar = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: detail_penjualan.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: detail_penjualan
                          .where((transaksi) => transaksi['pelanggan']
                                  ['NamaPelanggan']
                              .toLowerCase()
                              .contains(searchBar))
                          .length,
                      itemBuilder: (context, index) {
                        final filteredData = detail_penjualan
                            .where((transaksi) => transaksi['pelanggan']
                                    ['NamaPelanggan']
                                .toLowerCase()
                                .contains(searchBar))
                            .toList();
                        final transaksi = filteredData[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nama: ${transaksi['pelanggan']['NamaPelanggan']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      transaksi['TanggalPenjualan'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                // List Produk dalam transaksi
                                Column(
                                  children: (transaksi['detail_penjualan']
                                          as List)
                                      .map<Widget>(
                                        (produk) => Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                produk['produk']['NamaProduk'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Rp ${produk['produk']['Harga']}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.blueGrey[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    ' x ${produk['JumlahProduk']}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                Text(
                                  'Total: Rp ${transaksi['TotalHarga']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        confirmDelete(transaksi['PenjualanID']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
