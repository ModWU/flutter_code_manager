enum VideoSign {
  sun,
  lightning,
  star,
  favorite,
  hot,
}

enum VideoLayout {
  horizontal,
  vertical,
}

enum MarkType {
  vip, //vip
  advanced_request, //超前点播
  advance, //预告
  self_made, //自制
  hynna_bubble_pop, //独播
}

enum PlayType {
  normal,
  exclusive,
}

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

/*class HeaderItem with ItemMiXin {
  String _videoUrl;
  String _imgUrl;
  PlayType _playType;
  String _introduce;

  HeaderItem({
    String videoUrl,
    bool isVideo,
    String imgUrl,
    bool isAdvert = false,
    PlayType playType = PlayType.normal,
    String introduce,
  })  : _videoUrl = videoUrl,
        _imgUrl = imgUrl,
        _playType = playType,
        _introduce = introduce;

  String get introduce => _introduce;

  PlayType get playType => _playType;

  String get imgUrl => _imgUrl;

  String get videoUrl => _videoUrl;
}*/

class VideoItem {
  //顶部
  String _videoUrl;
  String _imgUrl;
  MarkType _markType;
  String _time;
  PlayType _playType;

  //底部
  VideoItemTitle _title;

  VideoItem({
    String videoUrl,
    String imgUrl,
    MarkType markType,
    String time,
    PlayType playType = PlayType.normal,
    VideoItemTitle title,
  })  : _videoUrl = videoUrl,
        _imgUrl = imgUrl,
        _markType = markType,
        _time = time,
        _playType = playType,
        _title = title;

  VideoItemTitle get title => _title;

  String get time => _time;

  MarkType get markType => _markType;

  String get imgUrl => _imgUrl;

  String get videoUrl => _videoUrl;

  PlayType get playType => _playType;
}

class VideoItemTitle {
  String _preTitle;
  VideoSign _centerSign;
  String _lastTitle;
  bool _rightArrow;
  VideoSign _descSign;
  String _desc;

  VideoItemTitle({
    String preTitle,
    VideoSign centerSign,
    String lastTitle,
    bool rightArrow,
    VideoSign descSign,
    String desc,
  })  : _preTitle = preTitle,
        _centerSign = centerSign,
        _lastTitle = lastTitle,
        _rightArrow = rightArrow,
        _descSign = descSign,
        _desc = desc;

  String get desc => _desc;

  String get lastTitle => _lastTitle;

  VideoSign get centerSign => _centerSign;

  VideoSign get descSign => _descSign;

  String get preTitle => _preTitle;

  bool get rightArrow => _rightArrow;
}

class VideoBottom {
  String _playTitle;
  VideoSign _playSign;
  String _playDesc;
  bool _isHasRefresh;

  VideoBottom(
      {String playTitle,
      VideoSign playSign,
      String playDesc,
      bool isHasRefresh = true})
      : _playTitle = playTitle,
        _playSign = playSign,
        _playDesc = playDesc,
        _isHasRefresh = isHasRefresh;

  bool get isHasRefresh => _isHasRefresh;

  VideoSign get playSign => _playSign;

  String get playDesc => _playDesc;

  String get playTitle => _playTitle;
}

class VideoItems {
  //顶部
  VideoItemTitle _title;
  VideoLayout _layout;

  //中间
  List<VideoItem> _items;

  //底部
  VideoBottom _bottom;

  VideoItems(
      {VideoItemTitle title,
      VideoLayout layout,
      List<VideoItem> items,
      VideoBottom bottom})
      : _title = title,
        _layout = layout,
        _items = items,
        _bottom = bottom;

  VideoBottom get bottom => _bottom;

  List<VideoItem> get items => _items;

  VideoLayout get layout => _layout;

  VideoItemTitle get title => _title;
}
