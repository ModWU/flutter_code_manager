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
  vip,//vip
  advanced_request,//超前点播
  advance,//预告
  self_made,//自制
  hynna_bubble_pop,//独播
}

enum PlayType {
  normal,
  exclusive,
}

class VideoItem {
  //顶部
  String _videoUrl;
  String _imgUrl;
  bool _isGif;
  MarkType _markType;
  String _time;
  PlayType _playType;

  //底部
  VideoItemTitle _title;

  VideoItem({
    String videoUrl,
    String imgUrl,
    bool isGif = false,
    MarkType markType,
    String time,
    PlayType playType = PlayType.normal,
    VideoItemTitle title,
  })  : _videoUrl = videoUrl,
        _imgUrl = imgUrl,
        _isGif = isGif,
        _markType = markType,
        _time = time,
        _playType = playType,
        _title = title;

  VideoItemTitle get title => _title;

  String get time => _time;

  MarkType get markType => _markType;

  bool get isGif => _isGif;

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

mixin ItemMiXin {}

class AdvertItem with ItemMiXin {
  String _url;
  bool _isVideo;
  String _title_1;
  String _title_2;
  String _rightDesc;
  bool _isNeedDownload;

  AdvertItem(
      {String url,
        bool isVideo = false,
        String title_1,
        String title_2,
        String rightDesc,
        bool isNeedDownload = false})
      : _url = url,
        _isVideo = isVideo,
        _title_1 = title_1,
        _title_2 = title_2,
        _rightDesc = rightDesc,
        _isNeedDownload = isNeedDownload;

  bool get isNeedDownload => _isNeedDownload;

  String get rightDesc => _rightDesc;

  String get title_2 => _title_2;

  String get title_1 => _title_1;

  bool get isVideo => _isVideo;

  String get url => _url;
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

class VideoItems with ItemMiXin {
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
      :_title = title,
        _layout = layout,
        _items = items,
        _bottom = bottom;

  VideoBottom get bottom => _bottom;

  List<VideoItem> get items => _items;

  VideoLayout get layout => _layout;

  VideoItemTitle get title => _title;
}



