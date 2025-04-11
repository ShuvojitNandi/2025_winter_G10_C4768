import 'package:flutter/material.dart';
import 'package:harvest/view/components/vendor_tile.dart';
import '../../model/vendor_model.dart';

class VendorTileGrid extends StatefulWidget {
  const VendorTileGrid(
      {super.key,
      required this.vendors,
      required this.customerId,
      this.emptyText = "No vendors to display",
      this.shrinkWrap = false,
      this.physics = const AlwaysScrollableScrollPhysics(),
      this.filter = "",
      this.customer = true});

  final String filter;

  final Stream<List<Vendor>> vendors;
  final String emptyText;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final bool customer;
  
  final dynamic customerId;

  @override
  State<VendorTileGrid> createState() => _VendorTileGridState();
}

bool matchBetween(String query, String text) {
  int queryIndex = 0;
  int textIndex = 0;

  while (textIndex < text.length && queryIndex < query.length) {
    String queryChar = query[queryIndex].toLowerCase();
    String textChar = text[textIndex].toLowerCase();

    if (queryChar == textChar) {
      queryIndex++;
    }
    textIndex++;
  }
  if (queryIndex >= query.length) return true;

  return false;
}

class _VendorTileGridState extends State<VendorTileGrid> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vendor>>(
        stream: widget.vendors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No vendor found'));
          }

          List<Vendor> vendorsToDisplay = (snapshot.data ?? []);
          vendorsToDisplay.retainWhere((vendor) {
            return matchBetween(widget.filter, vendor.vendor_name);
          });

          return vendorsToDisplay.isEmpty
              ? Center(child: Text(widget.emptyText))
              : GridView.builder(
                  shrinkWrap: widget.shrinkWrap,
                  physics: widget.physics,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: vendorsToDisplay.length,
                  itemBuilder: (context, index) {
                    return VendorTile(
                        vendor: vendorsToDisplay[index], customer: widget.customer, customerID: widget.customerId);
                  },
                );
        });
  }
}
