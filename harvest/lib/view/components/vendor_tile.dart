import 'package:flutter/material.dart';

import '../../model/vendor_model.dart';
import '../../controller/vendor_service.dart';
import '../../view/vendor_home.dart';

class VendorTile extends StatefulWidget {
  const VendorTile({super.key, required this.vendorId});
  final String vendorId;

  @override
  State<VendorTile> createState() => _VendorTileState();
}

class _VendorTileState extends State<VendorTile> {
  String? userName;
  List<String> userShops = [];

  final VendorService _vendorService = VendorService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Vendor?>(
      stream: _vendorService.getVendor(widget.vendorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No vendor found'));
        }

        Vendor vendor = snapshot.data!;
        final imageUrl = vendor.store_img.isNotEmpty
            ? vendor.store_img
            : 'https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorHomePage(vendorId: vendor.id!),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightGreenAccent,
                  blurRadius: 6,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: Icon(Icons.store, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    vendor.vendor_name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
