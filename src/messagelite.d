import wireformat;

class MessageLite: WireFormat
{
  this()
  {
    total_size = 0;
  }
  byte* SerializeWithCachedSizesToBytes(byte* target)
  {
    return target;
  }
  size_t GetCachedSize()
  {
    return 0;
  }
  size_t ByteSize()
  {
    return this.total_size;
  }
  
 private:
  uint total_size;
  uint cached_size;
}
class RepeatedField(T)
{
  void Add(T element)
  {
    elements ~= element;
    total_size += element.sizeof;
  }
  int Size()
  {
    return total_size;
  }
  T Get(int index)
  {
    return elements[index];
  }
  void RemoveLast()
  {
    elements = elements[0..length - 2];
  }
 private:
  T[] elements;
  int total_size;
}
class RepeatedPtrField(T)
{
  void Add(char[] element)
  {
    elements ~= element;
    total_size += element.length;
  }
  void Add(MessageLite[] element)
  {
    elements ~= cast(T)element;
    total_size += element.ByteCount();
  }
  int Size()
  {
    return total_size;
  }
  T Get(int index)
  {
    return elements[index];
  }
  void RemoveLast()
  {
    elements = elements[0..length - 2];
  }
 private:
  T[] elements;
  int total_size;
}
