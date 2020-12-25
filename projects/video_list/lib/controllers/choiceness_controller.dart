import '../models/choiceness_model.dart';
import '../models/base_model.dart';
import 'dart:math';

class ChoicenessController {
  static final _instance = ChoicenessController._();

  factory ChoicenessController() {
    return _instance;
  }

  const ChoicenessController._();

  static final List<VideoItemTitle> topTitles = [
    VideoItemTitle(preTitle: "猜你会追", rightArrow: true),
    VideoItemTitle(
        preTitle: "重磅",
        rightArrow: true,
        centerSign: VideoSign.sun,
        lastTitle: "VIP抽中秋盲盒",
        descSign: VideoSign.hot,
        desc: "黄晓明豪宅"),
    VideoItemTitle(preTitle: "大家都在刷", rightArrow: true, desc: "鹅家观影日历"),
    VideoItemTitle(preTitle: "同步剧场", rightArrow: true, desc: "热剧抢先看"),
    VideoItemTitle(
        preTitle: "综艺",
        rightArrow: true,
        centerSign: VideoSign.sun,
        lastTitle: "演员2周五晚8点回归",
        desc: "瓜分万元大奖"),
    VideoItemTitle(
        preTitle: "电影大片",
        centerSign: VideoSign.lightning,
        rightArrow: true,
        lastTitle: "国庆档电影征稿大赛"),
  ];

  static final List<VideoBottom> bottoms = [
    VideoBottom(playTitle: "英雄联盟S10赛程"),
    VideoBottom(
        playTitle: "今儿啥火", playSign: VideoSign.hot, playDesc: "三分钟看热片"),
    VideoBottom(playTitle: "更多电视剧"),
    VideoBottom(playTitle: "更多热播综艺"),
    VideoBottom(playTitle: "更多热播电影"),
    null,
    null,
  ];

  static  final List<String> videoUrlList = [
    "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
    "https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218114723HDu3hhxqIT.mp4",
    "https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218093206z8V1JuPlpe.mp4",
    "https://stream7.iqilu.com/10339/article/202002/18/2fca1c77730e54c7b500573c2437003f.mp4",
    "https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218025702PSiVKDB5ap.mp4",
    "https://stream7.iqilu.com/10339/upload_transcode/202002/18/202002181038474liyNnnSzz.mp4",
    "https://stream7.iqilu.com/10339/article/202002/18/02319a81c80afed90d9a2b9dc47f85b9.mp4",
    "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
    "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4",
    "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4",
    "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4",
    "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4",
    "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4",
    "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319104618910544.mp4",
    "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319125415785691.mp4",
    "http://vfx.mtime.cn/Video/2019/03/17/mp4/190317150237409904.mp4",
    "http://vfx.mtime.cn/Video/2019/03/14/mp4/190314223540373995.mp4",
    "http://vfx.mtime.cn/Video/2019/03/14/mp4/190314102306987969.mp4",
    "http://vfx.mtime.cn/Video/2019/03/13/mp4/190313094901111138.mp4",
    "http://vfx.mtime.cn/Video/2019/03/12/mp4/190312143927981075.mp4",
    "http://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533415853.mp4",
    "http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4",
  ];

  static  final List<VideoItemTitle> titles = [
    VideoItemTitle(preTitle: "【热门】男子徒手搬开一个400斤大石头"),
    VideoItemTitle(preTitle: "陈翔六点半：这礼物太幸运，我就不该要！"),
    VideoItemTitle(preTitle: "脱口秀决赛", lastTitle: "学霸爱情", desc: "李雪琴：我还有王建国"),
    VideoItemTitle(preTitle: "德云社", lastTitle: "亲子夏令营", desc: "岳云鹏被师弟蒙眼拖拽半米"),
    VideoItemTitle(
        preTitle: "在一起",
        centerSign: VideoSign.star,
        lastTitle: "温情首播",
        desc: "张嘉益演绎渐冻症医生"),
    VideoItemTitle(
        preTitle: "我喜欢你",
        centerSign: VideoSign.favorite,
        lastTitle: "爆款甜剧",
        desc: "赵露思挑衅霸总反被扑倒，只有不懂得人才知道背后隐藏的秘密，王思远不顾反对"),
    VideoItemTitle(
        preTitle: "心动的信号",
        centerSign: VideoSign.favorite,
        lastTitle: "霸总表白",
        desc: "张翰深情对视杨超越：乖"),
  ];

  static  final List<String> imgUrlList = [
    "http://pic31.nipic.com/20130711/8952533_164845225000_2.jpg",
    "https://cn.bing.com/th?id=OIP.xq1C2fmnSw5DEoRMC86vJwD6D6&pid=Api&rs=1",
    "http://5b0988e595225.cdn.sohucs.com/q_mini,c_zoom,w_640/images/20171007/f1cfa788964748a6b932b75c68954f26.gif",
  ];

  static  final List<String> timeList = ["2020-09-26", "2021-01-02", "全24集", null];

  List getRandomHeaderData() {
    var random = new Random();
    VideoItem headerImage1 = VideoItem(
      imgUrl: 'images/head1.jpg',
      title: VideoItemTitle(preTitle: "创业年代", desc: "冯绍峰袁姗姗致敬科技行业"),
    );

    VideoItem headerImage2 = VideoItem(
      imgUrl: 'images/head2.jpeg',
      title: VideoItemTitle(preTitle: "演员2", desc: "新版《三生三世》夜华痛哭挖素素双眼"),
    );

    VideoItem headerImage3 = VideoItem(
      imgUrl: 'images/head3.jpg',
      title: VideoItemTitle(
          preTitle: "我喜欢你",
          centerSign: VideoSign.favorite,
          lastTitle: "爆款甜剧",
          desc: "林雨申赵露思烟火迷恋"),
    );

    VideoItem headerImage4 = VideoItem(
      imgUrl: 'images/head4.jpeg',
      title: VideoItemTitle(preTitle: "1917 · 首播", desc: "\"一镜到底\"还原残酷战争"),
    );

    VideoItem headerImage5 = VideoItem(
      imgUrl: 'images/head5.jpg',
      title: VideoItemTitle(preTitle: "我在时间尽头等你", desc: "李鸿其李一桐演绎纯爱童话"),
    );

    AdvertItem headerImage6 = AdvertItem(
      name: "疯读小说",
      introduce: "免费手机都不要，就是你不对了",
      isApplication: true,
      detailUrl: "https://www.baidu.com/",
      iconUrl: "https://i.loli.net/2020/10/09/GvLS47z2DXTRkcq.png",
      videoUrl: videoUrlList[random.nextInt(videoUrlList.length)],
      showImgUrl: null,
    );

    List list = [
      headerImage2,
      headerImage3,
      headerImage4,
      headerImage5,
      headerImage6,
    ];

    list.sort((left, right) {
      double rafac = random.nextDouble();
      if (rafac < 0.4)
        return -1;
      else if (rafac > 0.6)
        return 1;
      else
        return 0;
    });
    return List.from(list.take(5))..insert(0, headerImage1);
  }

  List getRondomDataByAdd() {
    List data = [];
    var random = new Random();
    int count = random.nextInt(2) + 1;
    for (int i = 0; i < count; i++) {
      int titleIndex = random.nextInt(MarkType.values.length);
      int layoutIndex = random.nextInt(VideoLayout.values.length);
      int bottomIndex = random.nextInt(bottoms.length);
      int itemsLength = random.nextInt(12) + 6;
      double advertAssert = random.nextDouble();
      data.add(VideoItems(
          title: topTitles[titleIndex],
          layout: VideoLayout.values[layoutIndex],
          items: getRandomVideoItemList(itemsLength),
          bottom: bottoms[bottomIndex]));
      if (advertAssert > 0.7) {
        data.add(AdvertItem(
          name: "疯读小说",
          introduce: "免费手机都不要，就是你不对了",
          isApplication: true,
          detailUrl: "https://www.baidu.com/",
          iconUrl: "https://i.loli.net/2020/10/09/GvLS47z2DXTRkcq.png",
          videoUrl: videoUrlList[random.nextInt(videoUrlList.length)],
          showImgUrl: null,
        ));
      }
    }

    return data;
  }

  List updateChoicenessData(List oldDataList) {
    oldDataList.removeAt(0);
    List newDataList = [];
    newDataList.add(getRandomHeaderData());

    for (dynamic oldData in oldDataList) {
      if (oldData is VideoItems) {
        int length = oldData.items.length;
        VideoItems videoItems = VideoItems(
          title: oldData.title,
          layout: oldData.layout,
          items: getRandomVideoItemList(length),
          bottom: oldData.bottom,
        );
        newDataList.add(videoItems);
      } else if (oldData is AdvertItem) {
        //广告暂不处理
        newDataList.add(oldData);
      }
    }

    return newDataList;
  }

  List initChoicenessData() {
    List videoData = [];

    videoData.add(getRandomHeaderData());

    var random = new Random();
    for (int i = 0; i < 12; i++) {
      int titleIndex = random.nextInt(MarkType.values.length);
      int layoutIndex = random.nextInt(VideoLayout.values.length);
      int bottomIndex = random.nextInt(bottoms.length);
      int itemsLength = random.nextInt(12) + 6;
      double advertAssert = random.nextDouble();
      videoData.add(VideoItems(
          title: topTitles[titleIndex],
          layout: VideoLayout.values[layoutIndex],
          items: getRandomVideoItemList(itemsLength),
          bottom: bottoms[bottomIndex]));
      if (advertAssert > 0.7) {
        videoData.add(AdvertItem(
          name: "疯读小说",
          introduce: "免费手机都不要，就是你不对了",
          isApplication: true,
          detailUrl: "https://www.baidu.com/",
          iconUrl: "https://i.loli.net/2020/10/09/GvLS47z2DXTRkcq.png",
          videoUrl: videoUrlList[random.nextInt(videoUrlList.length)],
          showImgUrl: null,
        ));
      }
    }

    return videoData;
  }

  List<VideoItem> getRandomVideoItemList(int length) {
    List<VideoItem> items = [];

    var random = new Random();
    for (int i = 0; i < length; i++) {
      int imgUrlIndex = random.nextInt(imgUrlList.length);
      int markTypeIndex = random.nextInt(MarkType.values.length);
      int timeIndex = random.nextInt(timeList.length);

      int play_fac = random.nextInt(2);

      int title_fac = random.nextInt(titles.length);

      int title_is_fac = random.nextInt(2);

      items.add(VideoItem(
        videoUrl: videoUrlList[0],
        imgUrl: imgUrlList[imgUrlIndex],
        markType: imgUrlIndex.isOdd ? MarkType.values[markTypeIndex] : null,
        time: timeList[timeIndex],
        playType: play_fac == 0 ? PlayType.normal : PlayType.exclusive,
        title: title_is_fac == 0 ? titles[title_fac] : null,
      ));
    }

    return items;
  }
}
