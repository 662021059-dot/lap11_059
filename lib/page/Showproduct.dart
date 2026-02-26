import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lap11_059/models/BookModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BookModel>? books;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "รายการหนังสือ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFC107), // เหลืองทอง
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFBF0), // ขาวอมเหลืองอ่อน
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFC107), // วงโหลดสีเหลือง
              ),
            )
          : books == null || books!.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: books!.length,
              itemBuilder: (context, index) {
                final book = books![index];
                return _buildBookCard(book);
              },
            ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFFFE082)), // เส้นขอบเหลืองอ่อน
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD), // กล่องไอคอนเหลืองอ่อน
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Color(0xFFFFA000), // ไอคอนเหลืองเข้ม
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF5D4037), // น้ำตาลเข้ม อ่านง่าย
          ),
        ),
        subtitle: Text(
          "ผู้แต่ง: ${book.author}\nปีที่พิมพ์: ${book.publishedYear}",
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Color(0xFFFFA000),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("ไม่พบข้อมูลหนังสือ", style: TextStyle(color: Colors.grey)),
    );
  }

  Future<void> getList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      var url = Uri.parse("http://10.0.2.2:3000/api/books");
      var response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        setState(() {
          books = jsonList.map((item) => BookModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Error Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Catch Error: $e");
    }
  }
}
