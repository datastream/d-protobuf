import wireformat;
import io;
class MessageLite: WireFormat
{
  this()
  {
    super();
  }
  byte* SerializeWithCachedSizesToBytes(byte* target)
  {
    byte[] tmp = new byte[ByteSize()];
    target = tmp.ptr;
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
  void Serialize(ref CodedOutputStream output)
  {
  }
  uint cached_size;
private:
  uint total_size;
}
// unknow_field should be a array ?
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
