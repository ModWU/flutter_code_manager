class NetworkErrorCode {
  static final _instance = NetworkErrorCode._();

  factory NetworkErrorCode() {
    return _instance;
  }

  const NetworkErrorCode._();

  static const String video_play_error = "20300.10102";
  static const String network_connectivity_error = "20300.10103";

}