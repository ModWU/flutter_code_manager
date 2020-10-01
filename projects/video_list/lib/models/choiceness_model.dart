import 'base_model.dart';

class ChoicenessHeaderItem {

  String _videoUrl;
  String _imgUrl;
  bool _isAdvert;
  PlayType _playType;
  String _introduce;

  ChoicenessHeaderItem({
    String videoUrl,
    String imgUrl,
    bool isAdvert = false,
    PlayType playType = PlayType.normal,
    String introduce,
  })  : _videoUrl = videoUrl,
        _imgUrl = imgUrl,
        _isAdvert = isAdvert,
        _playType = playType,
        _introduce = introduce;

  String get introduce => _introduce;

  PlayType get playType => _playType;

  bool get isAdvert => _isAdvert;

  String get imgUrl => _imgUrl;

  String get videoUrl => _videoUrl;
}