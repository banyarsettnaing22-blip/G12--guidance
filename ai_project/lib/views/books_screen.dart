// lib/views/books_screen.dart
import 'package:flutter/material.dart';
import '../data/offline_data.dart';
import 'login_screen.dart';
import 'hybrid_pdf_viewer.dart'; // 👈 Import the new hybrid viewer

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final books = OfflineData.offlineBooks;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5A5A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'BOOKS',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          
          // Check if this book is offline or cloud
          final bool isOffline = book['is_offline'] == 'true';
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOffline 
                    ? const Color(0xFF76C843) // Green for offline books
                    : const Color(0xFFFF5A5A), // Red for cloud books
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Open with Hybrid PDF Viewer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HybridPdfViewerScreen(
                      title: book['display_name'] ?? 'PDF Viewer',
                      assetPath: book['asset_path'],
                      fileId: book['file_id'],
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline 
                        ? Icons.check_circle_outline 
                        : Icons.cloud_download_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    book['subject_code']!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  if (!isOffline) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Cloud',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}