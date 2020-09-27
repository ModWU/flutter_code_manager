
class Node<T> {
    Node _next;
	Node _previous;
	T _data;
	
	Node(T data) : _data = data;
	
	Node get next => _next;
	Node get previous => _previous;
	T get data => _data;
	
	set next(Node<T> value) {
	  if (value != null) {
	    if (value._previous != null)
		   value._previous._next = null;
		 
		 value._previous = this;
	  }
	  
	  if (_next != null) 
	    _next._previous = null;
		
	  _next = value;
	  
	}
	
	set previous(Node<T> value) {
	  if  (value != null) {
		 if (value._next != null) 
	        value._next._previous = null;
	     
		 value._next = this;
	  }
	  
	  if (_previous != null) 
	    _previous._next = null;
	  
	  _previous = value;
	}
 }

class Stack<T> {

  Node<T> _last;
  int _length;
  
  int get length => _length ?? 0;
  T pop() {
    if (_last == null) 
	  return null;
	  
    T data = _last.data;
	_last = _last.previous;
	
	if (_last != null)
	  _last.next = null;
	  
	return data;
  }
  
  T push(T data) {
  
    if (data == null)
	  return null;
	  
    Node<T> _newNode = Node(data);
	if (_last != null)
		_last.next = _newNode;
		
	_last = _newNode;
	return data;
  }
  
  printAll() {
    Node<T> current = _last;
	List<String> buffer = ['['];
    while(current != null) {
	  buffer.add(current.data.toString());
	  buffer.add(', ');
	  current = current.previous;
	}
	buffer.add(']');
	print(buffer.join(''));
  }
  
}

//如果读取次数比较多则通过数组实现比较好，实现方式如下：
//1.数组的长度可按一定规律进行扩展
//2.数组应该有头部指针和尾部指针以及实际存储数据的长度以及数组的容量长度，数据应该从头部指针开始插入
//3.只有当整个数组长度填满实际的数据时才扩展数组长度，可参考:Queue队列的实现形式
void main() async {
  Stack<String> stk = Stack();
  stk.push('A');
  stk.push('B');
  stk.push('C');
  stk.push('D');
  stk.printAll();
  stk.pop();
  stk.pop();
  stk.printAll();
  stk.push('E');
  stk.printAll();
  String str = stk.pop();
  print(str);
  str = stk.pop();
  print(str);
 
  stk.printAll();
}


