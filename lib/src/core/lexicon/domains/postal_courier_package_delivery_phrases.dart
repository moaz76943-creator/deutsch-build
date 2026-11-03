class PostalCourierPackageDeliveryPhrases {
  const PostalCourierPackageDeliveryPhrases();
  String trackingPrompt(String lang, String trk) =>
      lang == 'ar' ? 'يمكنك تتبع شحنتك عبر الرقم: $trk' : 'Track your parcel with tracking number: $trk';
}
