class GumroadProduct {
  GumroadProduct({
    this.success = false,
    this.product = const Product(),
  });

  final bool success;
  final Product product;

  factory GumroadProduct.fromJson(Map<String, dynamic> json) => GumroadProduct(
        success: json["success"],
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "product": product.toJson(),
      };
}

class Product {
  const Product({
    this.name = '',
    this.previewUrl = '',
    this.description = '',
    this.customizablePrice = false,
    this.requireShipping = false,
    this.customReceipt = '',
    this.customPermalink = '',
    this.subscriptionDuration = '',
    this.id = '',
    this.url = '',
    this.price = 0,
    this.currency = '',
    this.shortUrl = '',
    this.thumbnailUrl = '',
    this.formattedPrice = 'Loading...',
    this.published = false,
    this.shownOnProfile = false,
    this.deleted = false,
    this.customSummary = '',
    this.isTieredMembership = false,
    this.recurrences = const [],
    this.salesCount = 0,
    this.salesUsdCents = 0,
  });

  final String name;
  final String previewUrl;
  final String description;
  final bool customizablePrice;
  final bool requireShipping;
  final String customReceipt;
  final String customPermalink;
  final String subscriptionDuration;
  final String id;
  final dynamic url;
  final int price;
  final String currency;
  final String shortUrl;
  final String thumbnailUrl;
  final String formattedPrice;
  final bool published;
  final bool shownOnProfile;
  final bool deleted;
  final String customSummary;
  final bool isTieredMembership;
  final List<String> recurrences;
  final int salesCount;
  final int salesUsdCents;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
        previewUrl: json["preview_url"],
        description: json["description"],
        customizablePrice: json["customizable_price"],
        requireShipping: json["require_shipping"],
        customReceipt: json["custom_receipt"],
        customPermalink: json["custom_permalink"],
        subscriptionDuration: json["subscription_duration"],
        id: json["id"],
        url: json["url"],
        price: json["price"],
        currency: json["currency"],
        shortUrl: json["short_url"],
        thumbnailUrl: json["thumbnail_url"],
        formattedPrice: json["formatted_price"],
        published: json["published"],
        shownOnProfile: json["shown_on_profile"],
        deleted: json["deleted"],
        customSummary: json["custom_summary"],
        isTieredMembership: json["is_tiered_membership"],
        recurrences: List<String>.from(json["recurrences"].map((x) => x)),
        salesCount: json["sales_count"],
        salesUsdCents: json["sales_usd_cents"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "preview_url": previewUrl,
        "description": description,
        "customizable_price": customizablePrice,
        "require_shipping": requireShipping,
        "custom_receipt": customReceipt,
        "custom_permalink": customPermalink,
        "subscription_duration": subscriptionDuration,
        "id": id,
        "url": url,
        "price": price,
        "currency": currency,
        "short_url": shortUrl,
        "thumbnail_url": thumbnailUrl,
        "formatted_price": formattedPrice,
        "published": published,
        "shown_on_profile": shownOnProfile,
        "deleted": deleted,
        "custom_summary": customSummary,
        "is_tiered_membership": isTieredMembership,
        "recurrences": List<dynamic>.from(recurrences.map((x) => x)),
        "sales_count": salesCount,
        "sales_usd_cents": salesUsdCents,
      };
}
