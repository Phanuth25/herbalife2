class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final double point;

  Product({
    required this.id,
    required this.point,
    required this.name,
    required this.price,
    required this.image,
  });
}

List<Product> products = [
  Product(
    id: 1,
    name: "1457 | អាហារបំប៉នសម្រាប់អត្តពលិក",
    price: 43.95,
    image: "assets/images/herb3.png",
    point: 41.60,
  ),
  Product(
    id: 2,
    name: "1463 | អាហារបំប៉ន ២៤ សុីអរសេវិនដ្រាយ",
    price: 29.59,
    image: "assets/images/herb4.png",
    point: 24.90,
  ),
  Product(
    id: 3,
    name: "1829 | សុីមភ្លីប្រូប៉ាយអូទិក ៣០ក្រាម",
    price: 21.18,
    image: "assets/images/herb5.png",
    point: 20.45,
  ),
  Product(
    id: 4,
    name: "0141 | អាហារសុខភាពហ្វូមមូទ្បាវាន់ រសជាតិវ៉ាន់នីទ្បា 550ក្រាម",
    price: 25.86,
    image: "assets/images/herb6.png",
    point: 23.95,
  ),
  Product(
    id: 5,
    name: "0142 | អាហារសុខភាពហ្វូមមូទ្បាវាន់ រសជាតិសូកូទ្បា 550ក្រាម",
    price: 25.86,
    image: "assets/images/herb7.png",
    point: 23.95,
  ),
  Product(
    id: 6,
    name: "0143 | អាហារសុខភាពហ្វូមមូទ្បាវាន់ រសជាតិស្រ្តបីរី 550ក្រាម",
    price: 25.86,
    image: "assets/images/herb8.png",
    point: 23.95,
  ),
];