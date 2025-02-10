import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Pelanggan extends StatefulWidget {
  const Pelanggan({super.key});

  @override
  State<Pelanggan> createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  final SupabaseClient supabase = Supabase.instance.client;

  String searchBar = '';

  final List<Map<String, dynamic>> pelanggan = [];

  final _formKey = GlobalKey<FormState>(); // Validasi

  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController alamatPelangganController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();

  // Add Pelanggan
  Future<void> addPelanggan(
      String namaPelanggan, String alamat, String nomorTelepon) async {
    try {
      final existingPelanggan = await supabase
          .from('pelanggan')
          .select()
          .or('NamaPelanggan.eq.$namaPelanggan,NomorTelepon.eq.$nomorTelepon');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelanggan sudah ada!'),
        ),
      );

      await supabase.from('pelanggan').insert({
        'NamaPelanggan': namaPelanggan,
        'Alamat': alamat,
        'NomorTelepon': nomorTelepon,
      });

      fetchPelangan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil Menambahkan Pelanggan'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Menambahkan Pelanggan: $e'),
        ),
      );
    }
  }

  // Edit Pelanggan
  Future<void> editPelanggan(
      int id, String namaPelanggan, String alamat, String nomorTelepon) async {
    try {
      final existingPelanggan = await supabase
          .from('pelanggan')
          .select()
          .eq('NamaPelanggan', namaPelanggan)
          .neq('PelangganID', id)
          .maybeSingle();

      if (existingPelanggan != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nama Pelanggan sudah digunakan!'),
          ),
        );
        return;
      }

      await supabase.from('pelanggan').update({
        'NamaPelanggan': namaPelanggan,
        'Alamat': alamat,
        'NomorTelepon': nomorTelepon,
      }).eq('PelangganID', id);

      fetchPelangan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil Mengedit Pelanggan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Mengedit Data: $e')),
      );
    }
  }

  // Fetch Pelanggan
  Future<void> fetchPelangan() async {
    try {
      final response = await supabase.from('pelanggan').select();

      if (mounted) {
        setState(() {
          pelanggan.clear();
          pelanggan.addAll((response as List<dynamic>).map((pelanggan) {
            return {
              'Id': pelanggan['PelangganID'],
              'NamaPelanggan': pelanggan['NamaPelanggan'],
              'Alamat': pelanggan['Alamat'],
              'NomorTelepon': pelanggan['NomorTelepon'],
            };
          }).toList());
        });
      }

      print(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil pelanggan: $e')),
        );
      }
    }
  }

  // Delete Pelanggan
  Future<void> deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('PelangganID', id);
      fetchPelangan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan berhasil dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pelanggan: $e')),
      );
    }
  }

  @override
  void initState() {
    fetchPelangan();
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
              'Selamat Datang Pelanggan',
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
                labelText: 'Cari Pelanggan...',
                prefixIcon: Icon(Icons.search),
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
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: pelanggan.where((p) {
                  return p['NamaPelanggan'].toLowerCase().contains(searchBar);
                }).length,
                itemBuilder: (context, index) {
                  final filteringPelanggan = pelanggan.where((p) {
                    return p['NamaPelanggan'].toLowerCase().contains(searchBar);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          filteringPelanggan[index]['NamaPelanggan'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat : ${filteringPelanggan[index]['Alamat']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'No.Telp : ${filteringPelanggan[index]['NomorTelepon']}',
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
                              onPressed: () {
                                editPelanggans(pelanggan[index]);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text('Hapus Pelanggan'),
                                      content: Text(
                                          'Apakah Anda yakin ingin menghapus pelanggan ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext).pop();
                                            await deletePelanggan(
                                              pelanggan[index]['Id'],
                                            );
                                          },
                                          child: Text(
                                            'Hapus',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
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
        onPressed: addPelanggans,
        child: Icon(Icons.add),
      ),
    );
  }

  // Dialog Add Pelanggan
  void addPelanggans() {
    showDialog(
        context: context,
        builder: (BuildContext content) {
          return AlertDialog(
            title: Text('Tambahkan Pelanggan'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Pelanggan Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: namaPelangganController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      label: Text('Nama Pelanggan'),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: alamatPelangganController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.calculate_outlined),
                      label: Text('Alamat'),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No.Telp Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: nomorTeleponController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.price_change_outlined),
                      label: Text('Nomor Telepon'),
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
                            final namaPelanggan = namaPelangganController.text;
                            final alamat = alamatPelangganController.text;
                            final nomorTelepon = nomorTeleponController.text;

                            addPelanggan(namaPelanggan, alamat, nomorTelepon);
                            Navigator.of(context).pop();

                            namaPelangganController.clear();
                            alamatPelangganController.clear();
                            nomorTeleponController.clear();
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

  void editPelanggans(Map<String, dynamic> pelanggan) {
    namaPelangganController.text = pelanggan['NamaPelanggan'];
    alamatPelangganController.text = pelanggan['Alamat'];
    nomorTeleponController.text = pelanggan['NomorTelepon'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Pelanggan'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama Pelanggan Tidak Boleh Kosong'
                      : null,
                  controller: namaPelangganController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nama Pelanggan',
                  ),
                ),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Alamat Tidak Boleh Kosong'
                      : null,
                  controller: alamatPelangganController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on),
                    labelText: 'Alamat',
                  ),
                ),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nomor Telepon Tidak Boleh Kosong'
                      : null,
                  controller: nomorTeleponController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Nomor Telepon',
                  ),
                  keyboardType: TextInputType.phone,
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
                          editPelanggan(
                            pelanggan['Id'],
                            namaPelangganController.text,
                            alamatPelangganController.text,
                            nomorTeleponController.text,
                          );
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
