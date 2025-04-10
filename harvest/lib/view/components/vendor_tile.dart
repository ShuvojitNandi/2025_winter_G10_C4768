import 'package:flutter/material.dart';
import '../../model/vendor_model.dart';
import '../../view/vendor_home.dart';
import '../../view/customer_view_of_vendors.dart';

class VendorTile extends StatefulWidget {
  const VendorTile({super.key, required this.vendor, required this.customer});
  final Vendor vendor;
  final bool customer;

  @override
  State<VendorTile> createState() => _VendorTileState();
}

class _VendorTileState extends State<VendorTile> {
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.vendor.store_img.isNotEmpty
        ? widget.vendor.store_img
        : 'https://sjfm.ca/wp-content/uploads/2018/07/FarmersMarketLauchLogo.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widget.customer
                ? CustomerVendorPage(vendorId: widget.vendor.id!, vendorName:widget.vendor.vendor_name)
                : VendorHomePage(vendorId: widget.vendor.id!),
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
                widget.vendor.vendor_name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
