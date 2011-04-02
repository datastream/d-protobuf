import io;
import prototype;
import wireformatlite;

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
      if(!input.ReadRaw(buffer, len)) return false;
      ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
      CodedInputStream tmp_input = new CodedInputStream(&tmp);
      while(true)
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
    if(!ReadBytes(input, value)) return false;
    return true;
  }
  bool ReadPackedBytes(ref CodedInputStream input, ref byte[][] values, FieldType type)
  {
    uint len;
    if(!input.ReadVarint32(len)) return false;
    byte[] buffer;
    if(!input.ReadRaw(buffer, len)) return false;
    ZeroCopyInputStream tmp = new ZeroCopyInputStream(buffer);
    CodedInputStream tmp_input = new CodedInputStream(tmp);
    while(true)
    {
      byte[] value;
      if(!ReadBytes(tmp_input, value)) return false;
      values ~= value;
    }
    return true;
  }
  bool ReadString(ref CodedInputStream input, ref char[] value, FieldType type)
  {
    return ReadBytes(input, cast(byte[])value);
  }
  bool ReadRepeatedString(ref CodedInputStream input, ref char[][] values,  FieldType type)
  {
    return ReadRepeatedBytes(input, cast(byte[][])values);
  }
  bool ReadPackedString(ref CodedInputStream input, ref char[][] values, FieldType type)
  {
    return ReadPackedBytes(input, cast(byte[][])values);
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
    switch(GetTagWireType(tag))
    {
      case WireType.WIRETYPE_LENGTH_DELIMITED:
        {
          uint len;
          byte[] buffer;
          if(!ReadVarint32(len)) throw new Exception("Failed to skip length");
          unknown_fields.length = UInt32Size(tag) + UInt32Size(len);
          input.WriteVarint32ToBytes(unknown_fields,tag);
          input.WriteVarint32ToBytes(unknown_fields,len);
          input.WriteRaw(buffer, len);
          unknown_fields ~= buffer;
          break;
        }
      case WireType.WIRETYPE_VARINT:
        {
          uint digital;
          if(!ReadVarint32(digital)) throw new Exception("Failed to skip varint");
          unknown_fields.length = UInt32Size(tag) + UInt32Size(digital);
          input.WriteVarint32ToBytes(unknown_fields,tag);
          input.WriteVarint32ToBytes(unknown_fields,digital);
          break;
        }
      case WireType.WIRETYPE_FIXED32:
        {
          byte[] buffer;
          unknown_fields.length = UInt32Size(tag);
          input.WriteVarint32ToBytes(unknown_fields,tag);
          input.WriteRaw(buffer, 4);
          unknown_fields ~= buffer;
          break;
        }
      case WireType.WIRETYPE_FIXED64:
        {
          byte[] buffer;
          unknown_fields.length = UInt32Size(tag);
          input.WriteVarint32ToBytes(unknown_fields,tag);
          input.WriteRaw(buffer, 4);
          unknown_fields ~= buffer;
          break;
        }
      default:
        {
          throw new Exception("Wrong type");
        }
    }
  }
}
