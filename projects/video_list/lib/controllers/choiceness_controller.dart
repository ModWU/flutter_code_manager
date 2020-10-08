import '../models/choiceness_model.dart';
import '../models/base_model.dart';
import 'dart:math';

class ChoicenessController {

  static final _instance = ChoicenessController._();

  factory ChoicenessController() {
    return _instance;
  }

  const ChoicenessController._();

  List getChoicenessData() {

    List videoData = [];

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
      title: VideoItemTitle(preTitle: "我喜欢你", centerSign: VideoSign.favorite, lastTitle: "爆款甜剧", desc: "林雨申赵露思烟火迷恋"),
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
      iconUrl: "https://avatars3.githubusercontent.com/u/19513504?s=460&v=4",
      videoUrl: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
      showImgUrl: null,
   );

    videoData.add(headerImage1);
    videoData.add(headerImage2);
    videoData.add(headerImage3);
    videoData.add(headerImage4);
    videoData.add(headerImage5);
    videoData.add(headerImage6);


    List<VideoItemTitle> topTitles = [
      VideoItemTitle(preTitle: "猜你会追", rightArrow: true),
      VideoItemTitle(preTitle: "重磅", rightArrow: true, centerSign: VideoSign.sun, lastTitle: "VIP抽中秋盲盒", descSign: VideoSign.hot, desc: "黄晓明豪宅"),
      VideoItemTitle(preTitle: "大家都在刷", rightArrow: true, desc: "鹅家观影日历"),
      VideoItemTitle(preTitle: "同步剧场", rightArrow: true, desc: "热剧抢先看"),
      VideoItemTitle(preTitle: "综艺", rightArrow: true, centerSign: VideoSign.sun, lastTitle: "演员2周五晚8点回归", desc: "瓜分万元大奖"),
      VideoItemTitle(preTitle: "电影大片", centerSign: VideoSign.lightning, rightArrow: true, lastTitle: "国庆档电影征稿大赛"),
    ];

    List<VideoItemTitle> titles = [
      VideoItemTitle(preTitle: "【热门】男子徒手搬开一个400斤大石头"),
      VideoItemTitle(preTitle: "陈翔六点半：这礼物太幸运，我就不该要！"),
      VideoItemTitle(preTitle: "脱口秀决赛", lastTitle: "学霸爱情", desc: "李雪琴：我还有王建国"),
      VideoItemTitle(preTitle: "德云社", lastTitle: "亲子夏令营", desc: "岳云鹏被师弟蒙眼拖拽半米"),
      VideoItemTitle(preTitle: "在一起", centerSign: VideoSign.star, lastTitle: "温情首播", desc: "张嘉益演绎渐冻症医生"),
      VideoItemTitle(preTitle: "我喜欢你", centerSign: VideoSign.favorite, lastTitle: "爆款甜剧", desc: "赵露思挑衅霸总反被扑倒，只有不懂得人才知道背后隐藏的秘密，王思远不顾反对"),
      VideoItemTitle(preTitle: "心动的信号", centerSign: VideoSign.favorite, lastTitle: "霸总表白", desc: "张翰深情对视杨超越：乖"),
    ];

    List<VideoBottom> bottoms = [
      VideoBottom(playTitle: "英雄联盟S10赛程"),
      VideoBottom(playTitle: "今儿啥火", playSign: VideoSign.hot, playDesc: "三分钟看热片"),
      VideoBottom(playTitle: "更多电视剧"),
      VideoBottom(playTitle: "更多热播综艺"),
      VideoBottom(playTitle: "更多热播电影"),
      null,
      null,
    ];

    var random = new Random();
    for (int i = 0; i < 20; i++) {

      int top_title_fac = random.nextInt(topTitles.length);

      List<VideoItem> items = [];

      int item_count_fac = random.nextInt(18);
      int image_url_fac = random.nextInt(2);
      int mark_fac = random.nextInt(MarkType.values.length);

      int play_fac = random.nextInt(2);

      int title_fac = random.nextInt(titles.length);

      int bottom_title_fac = random.nextInt(bottoms.length);
      int title_is_fac = random.nextInt(2);

      int itemCount = 2 + item_count_fac;//2~20
      for (int i = 0; i < itemCount; i++) {
        int time_fac = random.nextInt(3);
        int mark_fac2 = random.nextInt(2);
        items.add(VideoItem(
            videoUrl: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
            imgUrl: item_count_fac.isEven ? (image_url_fac == 0 ? "http://pic31.nipic.com/20130711/8952533_164845225000_2.jpg" : "https://cn.bing.com/th?id=OIP.xq1C2fmnSw5DEoRMC86vJwD6D6&pid=Api&rs=1") : "http://5b0988e595225.cdn.sohucs.com/q_mini,c_zoom,w_640/images/20171007/f1cfa788964748a6b932b75c68954f26.gif",
            markType: mark_fac2 == 0 ? MarkType.values[mark_fac] : null,
            time: time_fac == 0 ? "2020-09-26" : (time_fac == 1 ? "全24集" : null),
            playType: play_fac == 0 ? PlayType.normal : PlayType.exclusive,
            title: title_is_fac == 0 ? titles[title_fac] : null,
        ));
      }

      videoData.add(VideoItems(
          title: topTitles[top_title_fac],
          layout: VideoLayout.values[random.nextInt(20) % VideoLayout.values.length],
          items: items,
          bottom: bottoms[bottom_title_fac],
      ));
    }

    return videoData;
  }

}