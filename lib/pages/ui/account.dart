import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _DashboardState();
}

class _DashboardState extends State<Account> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObsecure = true;

  final List<Map<String, dynamic>> user = [];
  final _formKey = GlobalKey<FormState>();

  // * Digunakan untuk menambahkan user kedalam database supabase
  Future<void> _addUser(String username, String password) async {
    try {
      await supabase.from('user').insert({
        'username': username,
        'password': password,
      });

      if (mounted) {
        fetchUser();
      }
    } catch (e) {
      if (mounted) {
        _showError(e);
      }
    }
  }

  // * Mengambil data dari supabase
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
      print(response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // Mengedit data dari supabase
  Future<void> editingUser(int id, String username, String password) async {
    try {
      await supabase.from('user').update({
        'username': username,
        'password': password,
      }).eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil Mengedit Data'),
          ),
        );
        fetchUser();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // Menghapus data
  Future<void> deleteUser(int userID) async {
    try {
      final response = await supabase.from('user').delete().eq('id', userID);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User Berhasil Dihapus'),
          ),
        );
      }

      fetchUser();
    } catch (e) {
      _showError(e);
    }
  }

  // Error Dialog
  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
      ),
    );
  }

  // * Berjalan ketika user pertama kali masuk ke dalam aplikasi
  @override
  void initState() {
    fetchUser();
    super.initState();
  }

  // * Digunakan untuk menghapus data yang tidak digunakan
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    fetchUser();
    super.dispose();
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
                    text: 'Para ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: 'Pelanggan ',
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
            Expanded(
              child: ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Color(0xFF96582F),
                          ),
                          title: Text(user[index]['username']),
                          subtitle: Text('Role : ${user[index]['role']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  editUser(user[index]);
                                },
                                icon: Icon(
                                  Icons.edit,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteUser(user[index]['id']);
                                },
                                icon: Icon(
                                  Icons.delete,
                                ),
                                color: Colors.red,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(),
                      ],
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Color(0xFFBB784C),
        foregroundColor: Colors.white,
        onPressed: addUser,
        child: Icon(Icons.add),
      ),
    );
  }

  // * Digunakan untuk memunculkan kotak alert dialog
  void addUser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tambah User',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      label: Text(
                        'Username',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password Tidak Boleh Kosong';
                      }
                      return null;
                    },
                    controller: passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObsecure = !isObsecure;
                          });
                        },
                        icon: Icon(
                          isObsecure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      label: Text(
                        'Password',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    obscureText: isObsecure,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(context);
                        },
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil Menambahkan User'),
                              ),
                            );

                            final username = usernameController.text;
                            final password = passwordController.text;

                            usernameController.clear();
                            passwordController.clear();

                            Navigator.of(context).pop();

                            _addUser(username, password);

                            fetchUser();
                          }
                        },
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        );
      },
    );
  }

  // Dialog Untuk Memunculkan Alert Dialog Yang digunakan untuk Edit
  void editUser(Map<String, dynamic> userData) {
    usernameController.text = userData['username'];
    passwordController.text = userData['password'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit User',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username Tidak Boleh Kosong';
                    }
                    return null;
                  },
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Username',
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password Tidak Boleh Kosong';
                    }
                    return null;
                  },
                  controller: passwordController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isObsecure = !isObsecure;
                        });
                      },
                      icon: Icon(
                        isObsecure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    labelText: 'Password',
                  ),
                  obscureText: isObsecure,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child:
                          Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          editingUser(
                            userData['id'],
                            usernameController.text,
                            passwordController.text,
                          );
                          Navigator.of(context).pop(); // Tutup dialog
                        }
                      },
                      child:
                          Text('Simpan', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
