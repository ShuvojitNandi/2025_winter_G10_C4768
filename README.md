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


## In the future, the vendor document will include a field 'products' that maps a product ID to vendor-specific details like price and available quantity