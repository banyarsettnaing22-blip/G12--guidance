// lib/views/hybrid_pdf_viewer.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HybridPdfViewerScreen extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String? fileId;

  const HybridPdfViewerScreen({
    super.key,
    required this.title,
    this.assetPath,
    this.fileId,
  });

  @override
  State<HybridPdfViewerScreen> createState() => _HybridPdfViewerScreenState();
}

class _HybridPdfViewerScreenState extends State<HybridPdfViewerScreen> {
  // ============================================================
  // 🔧 Appwrite Configuration - UPDATE THESE WITH YOUR VALUES
  // ============================================================
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6a85ef5f003d10eb304d'; // 👈 YOUR PROJECT ID
  static const String bucketId = '6a8afd05000ffb3c89a5'; // 👈 YOUR BUCKET ID

  Uint8List? _cloudPdfBytes;
  bool _isLoading = false;
  String? _errorMessage;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Only fetch from cloud if there's NO local asset but HAS file_id
    final hasAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;
    final hasFileId = widget.fileId != null && widget.fileId!.isNotEmpty;
    
    if (!hasAsset && hasFileId) {
      _fetchCloudPdf();
    }
  }

  Future<void> _fetchCloudPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = 0.0;
    });

    final url = '$endpoint/storage/buckets/$bucketId/files/${widget.fileId}/view?project=$projectId';

    try {
      // Download with progress tracking
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength;
        final bytes = await response.stream.fold<Uint8List>(
          Uint8List(0),
          (acc, chunk) {
            if (contentLength != null) {
              final progress = (acc.length + chunk.length) / contentLength;
              setState(() {
                _downloadProgress = progress.clamp(0.0, 1.0);
              });
            }
            final newAcc = Uint8List(acc.length + chunk.length)
              ..setAll(0, acc)
              ..setAll(acc.length, chunk);
            return newAcc;
          },
        );
        
        setState(() {
          _cloudPdfBytes = bytes;
          _isLoading = false;
          _downloadProgress = 1.0;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load PDF (HTTP ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocalAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFFFF5A5A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          // ==========================================================
          // 1️⃣ LOCAL ASSET - Instant open (Offline)
          // ==========================================================
          if (isLocalAsset) {
            return SfPdfViewer.asset(
              widget.assetPath!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoadFailed: (details) {
                _showError(details.description);
              },
            );
          }

          // ==========================================================
          // 2️⃣ DOWNLOADING from Cloud - Show progress
          // ==========================================================
          if (_isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: _downloadProgress < 1.0 ? _downloadProgress : null,
                      color: const Color(0xFFFF5A5A),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _downloadProgress < 1.0
                        ? 'Downloading ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                        : 'Processing...',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please wait while the PDF is downloaded',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ==========================================================
          // 3️⃣ ERROR STATE - Show error with retry
          // ==========================================================
          if (_errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchCloudPdf,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5A5A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==========================================================
          // 4️⃣ CLOUD PDF LOADED - Render from memory
          // ==========================================================
          if (_cloudPdfBytes != null) {
            return SfPdfViewer.memory(
              _cloudPdfBytes!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoadFailed: (details) {
                _showError(details.description);
              },
            );
          }

          // ==========================================================
          // 5️⃣ FALLBACK - No PDF found
          // ==========================================================
          return const Center(
            child: Text(
              'PDF not found for this subject.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }

  void _showError(String description) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load PDF: $description'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}