## What is changed from Vendor_home_page branch
1. Rather than saving the vendor details under Users collections, we now have 3 collections:
  - users
  - vendors
  - products
  - categories

2. Vendor model now look like this: 
```dart
class Vendor {
  final String? id;
  final String vendor_name;
  final String store_img;

  final String store_descrip;
  List<String> conf_dates;
  List<String> owners;
  final String email;
  final String phone;
  final String? website;
  final String? facebook;
  final String? instagram;
```
where the `owners` list stores the uid of user/users. 

3. Homepage has a button through which user can register for their shop. Right now, the form takes a picture, name, website and other info. Upon registering the homepage updates and shows a vendor card .  This new tile/card take us to the VendorHomePage() . This part needs further modification.

## Vendor/store IDs in the User Document 

```dart

UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.shops,
  });

```
By storing the vendor IDs in the shops array, the app can quickly display the stores owned by the user on their homepage. As the app grows, this approach helps in efficiently retrieving and displaying vendor data for each user.


## Separate Products Collection
- A separate products collection will allow for fast queries when users search for products to add to their cart later. 

- Product name, description, price, and image are stored centrally, avoiding duplication across multiple vendor documents.

- While the global product data remains in one collection, vendors can maintain vendor-specific details like  pricing, quantity, or offers by referencing product IDs in their document.


###  In the future, the vendor document will include a field 'products' (dynamic list, like python dictionary) that maps a product ID to vendor-specific details like price and available quantity
