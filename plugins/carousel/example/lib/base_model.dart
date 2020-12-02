class AdvertItem {
  String _name;
  String _iconUrl;
  String _showImgUrl;
  String _videoUrl;
  String _detailUrl;
  String _introduce;
  bool _isApplication;

  AdvertItem(
      {String videoUrl,
        String iconUrl,
        String detailUrl,
        String showImgUrl,
        String introduce,
        String name,
        bool isApplication = false})
      :_iconUrl = iconUrl,
        _videoUrl = videoUrl,
        _introduce = introduce,
        _showImgUrl = showImgUrl,
        _detailUrl = detailUrl,
        _name = name,
        _isApplication = isApplication;

  bool get canPlay => _videoUrl != null;

  String get videoUrl => _videoUrl;

  String get introduce => _introduce;

  String get name => _name;

  String get showImgUrl => _showImgUrl;

  String get iconUrl => _iconUrl;

  String get detailUrl => _detailUrl;

  bool get isApplication => _isApplication;
}