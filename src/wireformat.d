import io;
import prototype;
import wireformatlite;
import tango.io.Stdout;
class WireFormat : WireFormatLite
{
  bool ReadRepeatedPrimitive(V)(ref CodedInputStream input, ref V[] values, FieldType type)
  {
    V value;
    if(!ReadPrimitive!(V)(input, value, type)) return false;
    values ~= value;
    return true;
  }
  bool ReadPackedPrimitive(V)(uint tag_size, uint tag, ref CodedInputStream input, ref V[] values, FieldType type)
  {
    if(UInt32Size(tag) == tag_size) {
      uint len;
      if(!input.ReadVarint32(len)) return false;
      byte[] buffer;
      buffer.length = len;
      if(!input.ReadRaw(buffer, len)) return false;
      ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
      CodedInputStream tmp_input = new CodedInputStream(&tmp);
      while(tmp_input.BufferSize() > 0)
      {
       V value;
       if(!ReadPrimitive!(V)(tmp_input, value, type)) return false;
       values ~= value;
      }
    }
    return true;
  }
  bool ReadBytes(ref CodedInputStream input, ref byte[] value, FieldType type)
  {
    uint len;
    if(!input.ReadVarint32(len)) return false;
    if(!input.ReadRaw(value, len)) return false;
  }
  bool ReadRepeatedBytes(ref CodedInputStream input, ref byte[][] values, FieldType type)
  {
    byte[] value;
    if(!ReadBytes(input, value, type)) return false;
    values ~= value;
    return true;
  }
  bool ReadPackedBytes(ref CodedInputStream input, ref byte[][] values, FieldType type)
  {
    uint len;
    if(!input.ReadVarint32(len)) return false;
    byte[] buffer;
    if(!input.ReadRaw(buffer, len)) return false;
    ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
    CodedInputStream tmp_input = new CodedInputStream(&tmp);
    while(true)
    {
      byte[] value;
      if(!ReadBytes(tmp_input, value, type)) return false;
      values ~= value;
    }
    return true;
  }
  bool ReadString(ref CodedInputStream input, ref char[] value, FieldType type)
  {
    uint len;
    if(!input.ReadVarint32(len)) return false;
    if(!input.ReadString(value, len)) return false;
  }
  bool ReadRepeatedString(ref CodedInputStream input, ref char[][] values,  FieldType type)
  {
    char[] value;
    if(!ReadString(input, value, type)) return false;
    values ~= value;
    return true;
  }
  bool ReadPackedString(ref CodedInputStream input, ref char[][] values, FieldType type)
  {
    uint len;
    if(!input.ReadVarint32(len)) return false;
    char[] buffer;
    if(!input.ReadString(buffer, len)) return false;
    ZeroCopyInputStream tmp = new ZeroCopyInputStream(cast(byte[])buffer);
    CodedInputStream tmp_input = new CodedInputStream(&tmp);
    while(true)
    {
      char[] value;
      if(!ReadString(tmp_input, value, type)) return false;
      values ~= value;
    }
    return true;
  }
  bool ReadMeaasge(V)(ref CodedInputStream input, ref V value, FieldType type)
  {
    uint len;
    if(!ReadVarint32(len)) return false;
    byte[] buffer;
    if(!input.ReadRaw(buffer, len)) return false;
    ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
    CodedInputStream tmp_input = new CodedInputStream(tmp);
    value.MergePartialFromStream(tmp_input);
    return true;
  }
  bool ReadPackedMessage(V)(ref CodedInputStream input, ref V[] values, FieldType type)
  {
    V value;
    uint len;
    if(!ReadVarint32(len)) return false;
    byte[] buffer;
    if(!input.ReadRaw(buffer, len)) return false;
    ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
    CodedInputStream tmp_input = new CodedInputStream(tmp);
    while(true)
    {
      if(!ReadMeaasge!(V)(tmp_input, value)) return false;
      values ~= value;
    }
    return true;
  }
  void SkipField(ref CodedInputStream input, uint tag , byte[] unknown_fields)
  {
    CodedOutputStream tmp = new CodedOutputStream;
    CodedOutputStream* output = &tmp;
    switch(GetTagWireType(tag))
    {
      case WireType.WIRETYPE_LENGTH_DELIMITED:
        {
          uint len;
          byte[] buffer;
          if(!input.ReadVarint32(len)) throw new Exception("Failed to skip length");
          byte *unknown = buffer.ptr;
          buffer.length = UInt32Size(tag) + UInt32Size(len);
          output.WriteVarint32ToBytes(tag, unknown);
          output.WriteVarint32ToBytes(len, unknown);
          unknown_fields ~= buffer;
          buffer.length = len;
          input.ReadRaw(buffer, len);
          unknown_fields ~= buffer;
          break;
        }
      case WireType.WIRETYPE_VARINT:
        {
          uint digital;
          byte[] buffer;
          if(!input.ReadVarint32(digital)) throw new Exception("Failed to skip varint");
          byte *unknown = buffer.ptr;
          buffer.length = UInt32Size(tag) + UInt32Size(digital);
          output.WriteVarint32ToBytes(tag,unknown);
          output.WriteVarint32ToBytes(digital,unknown);
          unknown_fields ~= buffer;
          break;
        }
      case WireType.WIRETYPE_FIXED32:
        {
          byte[] buffer;
          byte *unknown = buffer.ptr;
          buffer.length = UInt32Size(tag);
          output.WriteVarint32ToBytes(tag,unknown);
          input.ReadRaw(buffer, 4);
          unknown_fields ~= buffer;
          break;
        }
      case WireType.WIRETYPE_FIXED64:
        {
          byte[] buffer;
          byte *unknown = buffer.ptr;
          buffer.length = UInt32Size(tag);
          output.WriteVarint32ToBytes(tag,unknown);
          input.ReadRaw(buffer, 8);
          unknown_fields ~= buffer;
          break;
        }
      default:
        {
          throw new Exception("Wrong type");
        }
    }
  }
  this()
  {
    super();
  }
}
