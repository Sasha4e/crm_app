// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/storage/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Для форматирования даты

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoaded = false;
  var image;
  final TextEditingController _first_name = TextEditingController();
  final TextEditingController _last_name = TextEditingController();
  final TextEditingController _fathername = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  late Map<String, dynamic> userData;
  String? base64Image;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path); // Сохраняем файл изображения
        base64Image = base64Encode(image
            .readAsBytesSync()); // Преобразуем его в base64 строку, если это необходимо
        updateImg();
      });
    }
  }

  Future<void> updateImg() async {
    try {
      var response =
          await ApiClient.postData('users', {'image': image, '_method': 'PUT'});
      if (response.statusCode == 200) {
        setState(() {});
        var jsonResponse = json.decode(response.body);

        print('response: ${jsonResponse['data']}');
        fetchData();
      } else {
        print('Failed to fetch updateImg. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      var response = await ApiClient.get('auth/me');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          userData = jsonResponse['data'];
          isLoaded = true;
          print('--------SUCCESSFULLY GOT USER----------');
          _first_name.text =
              userData['first_name'] != null ? userData['first_name'] : '';
          _last_name.text =
              userData['last_name'] != null ? userData['last_name'] : '';
          _fathername.text =
              userData['fathername'] != null ? userData['fathername'] : '';
          _dateController.text =
              userData['birthday'] != null ? userData['birthday'] : '';
          _phone.text = userData['phone'] != null ? userData['phone'] : '';
          _email.text = userData['email'] != null ? userData['email'] : '';
        });
        await UserStorage.saveUserData(userData);
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updateDate();
    }
  }

  Future<void> _updateDate() async {
    try {
      var response =
          await ApiClient.post('users', {'birth_date': _dateController.text});
      if (response.statusCode == 200) {
        print('Date updated successfully');
      } else {
        print('Failed to update date. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          child: isLoaded
              ? Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: userData['image'] != null
                              ? NetworkImage(userData['image'])
                              : NetworkImage(
                                  'http://stage.newcrm.projects.od.ua/img/avatar-placeholder.d45784a3.jpg'),
                          radius: 60,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await pickImageFromGallery();
                            },
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _first_name,
                      decoration:
                          const InputDecoration(labelText: 'First name'),
                    ),
                    TextField(
                      controller: _last_name,
                      decoration: const InputDecoration(labelText: 'Last name'),
                    ),
                    TextField(
                      controller: _fathername,
                      decoration:
                          const InputDecoration(labelText: 'Father name'),
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date of birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                    TextField(
                      controller: _phone,
                      decoration:
                          const InputDecoration(labelText: 'Phone number'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 45.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 1, 77, 139),
                              fixedSize: Size(200, 50)),
                          onPressed: () async {
                            var response = await ApiClient.put('users', {
                              'firstname': _first_name.text,
                              'lastname': _last_name.text,
                              'fathersname': _fathername.text,
                              'email_addres': _email.text,
                              'phone': _phone.text,
                              'birthday': _dateController.text,
                            });

                            if (response.statusCode == 200) {
                              var jsonResponse = json.decode(response.body);

                              print('jsonResponse: $jsonResponse');
                              fetchData();

                              setState(() {});
                            } else {
                              print(
                                  'Failed to set data. Status code: ${response.statusCode}');
                              print('Response body: ${response.body}');
                            }
                          },
                          child: Text('Save',
                              style: TextStyle(color: Colors.white))),
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
