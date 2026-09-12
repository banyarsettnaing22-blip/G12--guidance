import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HybridPdfViewerScreen extends StatefulWidget {
  final String title;
  final String? assetPath;
  final String? fileId;
  final Color themeColor;

  const HybridPdfViewerScreen({
    super.key,
    required this.title,
    this.assetPath,
    this.fileId,
    this.themeColor = const Color(0xFF2948FF),
  });

  @override
  State<HybridPdfViewerScreen> createState() => _HybridPdfViewerScreenState();
}

class _HybridPdfViewerScreenState extends State<HybridPdfViewerScreen> {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6a85ef5f003d10eb304d';
  static const String bucketId = '6a8afd05000ffb3c89a5';

  late PdfViewerController _pdfViewerController;
  late TextEditingController _pageNumberController;
  int _currentPage = 1;
  int _pageCount = 0;

  Uint8List? _cloudPdfBytes;
  bool _isLoading = false;
  String? _errorMessage;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _pageNumberController = TextEditingController(text: '1');

    final hasAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;
    final hasFileId = widget.fileId != null && widget.fileId!.isNotEmpty;

    if (!hasAsset && hasFileId) {
      _fetchCloudPdf();
    }
  }

  @override
  void dispose() {
    _pageNumberController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _fetchCloudPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = 0.0;
    });

    final url = '$endpoint/storage/buckets/$bucketId/files/${widget.fileId}/view?project=$projectId';

    try {
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

  void _showJumpToPageDialog() {
    final TextEditingController dialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Go to Page'),
          content: TextField(
            controller: dialogController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: _pageCount > 0 ? 'Enter page (1 - $_pageCount)' : 'Enter page number',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2948FF),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final page = int.tryParse(dialogController.text);
                if (page != null && page >= 1 && (_pageCount == 0 || page <= _pageCount)) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocalAsset = widget.assetPath != null && widget.assetPath!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B2B),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF2948FF),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.find_in_page, color: Colors.white),
            tooltip: 'Jump to Page',
            onPressed: _showJumpToPageDialog,
          ),
          IconButton(
            icon: const Icon(Icons.star_rounded, color: Colors.white70, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              if (isLocalAsset) {
                return SfPdfViewer.asset(
                  widget.assetPath!,
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                      _pageNumberController.text = details.newPageNumber.toString();
                    });
                  },
                  onDocumentLoadFailed: (details) {
                    _showError(details.description);
                  },
                );
              }

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
                          color: const Color(0xFF4EE3FF),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _downloadProgress < 1.0
                            ? 'Downloading ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                            : 'Processing...',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              if (_errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCloudPdf,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2948FF)),
                        child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              if (_cloudPdfBytes != null) {
                return SfPdfViewer.memory(
                  _cloudPdfBytes!,
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                      _pageNumberController.text = details.newPageNumber.toString();
                    });
                  },
                  onDocumentLoadFailed: (details) {
                    _showError(details.description);
                  },
                );
              }

              return const Center(child: Text('PDF not found.', style: TextStyle(color: Colors.white70)));
            },
          ),

          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4EE3FF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.hub_outlined, color: Colors.black87, size: 24),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2CB8),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
              tooltip: 'Previous Page',
              onPressed: _currentPage > 1 ? () => _pdfViewerController.previousPage() : null,
            ),
            Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 36,
                  child: TextField(
                    controller: _pageNumberController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (value) {
                      final targetPage = int.tryParse(value);
                      if (targetPage != null && targetPage >= 1 && (_pageCount == 0 || targetPage <= _pageCount)) {
                        _pdfViewerController.jumpToPage(targetPage);
                      } else {
                        _pageNumberController.text = _currentPage.toString();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _pageCount > 0 ? '/ $_pageCount' : '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
              tooltip: 'Next Page',
              onPressed: (_pageCount == 0 || _currentPage < _pageCount) ? () => _pdfViewerController.nextPage() : null,
            ),
          ],
        ),
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