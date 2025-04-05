import 'package:flutter/material.dart';

import 'package:harvest/view/components/vendor_tile.dart';

class VendorTileGrid extends StatefulWidget {
  const VendorTileGrid(
      {super.key,
      required this.userShops,
      this.emptyText = "No vendors to display",
      this.shrinkWrap = false,
      this.physics = const AlwaysScrollableScrollPhysics(),});

  final List<String> userShops;
  final String emptyText;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  State<VendorTileGrid> createState() => _VendorTileGridState();
}

class _VendorTileGridState extends State<VendorTileGrid> {
  @override
  Widget build(BuildContext context) {
    return widget.userShops.isEmpty
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
            itemCount: widget.userShops.length,
            itemBuilder: (context, index) {
              return VendorTile(vendorId: widget.userShops[index]);
            },
          );
  }
}
