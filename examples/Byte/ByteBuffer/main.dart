import "dart:typed_data";

main() {
  
  //exam_1();
  exam_2();
}

exam_2() {
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 01000000]
  ByteData data = getBaseByteData();
  ByteBuffer buffer = data.buffer;
  
  //[10010010, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 01000000]
  data.setInt8(0, -110);
  Int8List list_8 = buffer.asInt8List();
  print("list_8: $list_8");
  
  //取数组中的所有数据，保存在新的list中，数组长度为：64 ~/ 16 = 4
  Uint16List list_16 = buffer.asUint16List();
  print("list_16: $list_16");
  
  //取数组中的所有数据，保存在新的list中，数组长度为：64 ~/ 32 = 2
  Uint32List list_32 = buffer.asUint32List();
  print("list_32: $list_32");
  
  
  //取数组中的所有数据，保存在新的list中，数组长度为：64 ~/ 64 = 1
  Uint64List list_64 = buffer.asUint64List();
  print("list_64: $list_64");
}

exam_1() {
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 01000000]
  ByteData data = getBaseByteData();
  ByteBuffer buffer = data.buffer;
  
  Int8List list_1 = buffer.asInt8List();
  print("list_1: $list_1");
  
   //-73和183的后8位、-76和180的后8位分别在计算机内存中表现一致
  Uint8List list_2 = buffer.asUint8List();
  print("list_2: $list_2");
  
  //数组依然为：[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 01000000] 
  //此时会产生一个新的ByteData对象，但是对象中的数组指向同一个，即data2.buffer = data.buffer
  //但是data2的字段为： lengthInBytes = 4，offsetInBytes = 3。但是data2.buffer.lengthInBytes依然为8
  ByteData data2 = buffer.asByteData(3, 4);
  print("${data.buffer.hashCode} ${data2.buffer.hashCode}");
  
  //此时获取data2中第一个数为：0 + offsetInBytes = 3，即偏移第3个数，得到：00101000，转化为十进制为：40
  var first_data2 = data2.getInt8(0);
  print("first_data2: ${first_data2}");
  
  //buffer对象还是同一个
  var buffer2 = data2.buffer;
  print("${buffer2.hashCode} ${buffer.hashCode}");
  
  print("data2的buffer多少个字节：${data2.buffer.lengthInBytes}");
  print("data2多少个字节：${data2.lengthInBytes}");
  print("data2每个元素表示的字节数：${data2.elementSizeInBytes}");
  print("data2在字节数组中的偏移量：${data2.offsetInBytes}");
}

ByteData getBaseByteData() {
	//初始数组：[00000000, 00000000, 00000000, 00000000, 00000000, 00000000, 00000000, 00000000]
  var data = ByteData(8);
  ByteBuffer buffer = data.buffer;
  
  //[00100000, 00000000, 00000000, 00000000, 00000000, 00000000, 00000000, 00000000]
  data.setInt8(0, 32);
  
  //[00100000, 10110100, 00000000, 00000000, 00000000, 00000000, 00000000, 00000000]
  data.setInt8(1, -76);
  
  //[00100000, 10110100, 10110111, 00000000, 00000000, 00000000, 00000000, 00000000]
  data.setInt8(2, 183);
  
  //[00100000, 10110100, 10110111, 00101000, 00000000, 00000000, 00000000, 00000000]
  data.setInt8(3, 40);
  
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000000, 00000000, 00000000]
  data.setInt8(4, 2);
  
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00000000, 00000000]
  data.setInt8(5, 4);
  
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 00000000]
  data.setInt8(6, 52);
  
  //[00100000, 10110100, 10110111, 00101000, 00000010, 00000100, 00110100, 01000000]
  data.setInt8(7, 64);
  
  return data;
}