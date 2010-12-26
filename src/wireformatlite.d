private import tango.io.Stdout;
private import commen;
private import io;

private alias char[] string;

struct ExtensionIdentifier(T,V)
{
  bool repeated_;
  Type type_;
  int number_;
  bool packed_;
  T value_;
  V v_type_;
}
class WireFormatLite
{
  static const WireType[FieldType] WireTypeForFieldType;
  // Number of bits in a tag which identify the wire type.
  static const int TagTypeBits = 3;
  // Mask for those bits.
  static const uint TagTypeMask = (1 << TagTypeBits) - 1;

  static uint ZigZagEncode32(int n)
  {
    return (n << 1) ^ (n >> 31);
  }
  static ulong ZigZagEncode64(long n)
  {
    return (n << 1) ^ (n >> 63);
  }
  static int ZigZagDecode32(uint n)
  {
    return (n >> 1)^-cast(int)( n & 1);
  }
  static long ZigZagDecode64(ulong n)
  {
    return (n >> 1)^-cast(long)( n & 1);
  }
  static uint EncodeFloat(float value)
  {
    union U {float f; uint i;};
    U u;
    u.f = value;
    return u.i;
  }
  static float DecodeFloat(uint value)
  {
    union U {float f; uint i;};
    U u;
    u.i = value;
    return u.f;
  }
  static  ulong EncodeDouble(double value)
  {
    union U {double f; ulong i;};
    U u;
    u.f = value;
    return u.i;
  }
  static double DecodeDouble(ulong value)
  {
    union U {double f; ulong i;};
    U u;
    u.i = value;
    return u.f;
  }
  static uint MakeTag(int field_number, WireType type)
  {
    return (field_number << TagTypeBits) | type;
  }
  /*
   * Read functions
   */
  bool ReadPrimitive(V, T)(CodedInputStream input, ref V value)
  {
    if(T == Type.TYPE_INT32) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(int)tmp;
    }
    if(T == Type.TYPE_INT64) {
      long tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = cast(long)tmp;      
    }
    if(T == Type.TYPE_UINT32) {
      return input.ReadVarint32(value);
    }
    if(T == Type.TYPE_UINT64) {
      return input.ReadVarint64(value);
    }
    if(T == Type.TYPE_SINT32) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = ZigZagDecode32(tmp);
    }
    if(T == Type.TYPE_SINT64) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = ZigZagDecode64(tmp);
    }
    if(T == Type.TYPE_FIXED32) {
      return input.ReadLittleEndian32(value);
    }
    if(T == Type.TYPE_FIXED64) {
      return input.ReadLittleEndian64(value);
    }
    if(T == Type.TYPE_SFIXED32) {
      uint tmp;
      if(!input.ReadLittleEndian32(tmp)) return false;
      value = cast(int)tmp;
    }
    if(T == Type.TYPE_SFIXED64) {
      ulong tmp;
      if(!input.ReadLittleEndian64(tmp)) return false;
      value = cast(long)tmp;
    }
    if(T == Type.TYPE_FLOAT) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = DecodeFloat(tmp);
    }
    if(T == Type.TYPE_DOUBLE) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = DecodeDouble(tmp);
    }
    if(T == Type.TYPE_BOOL) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = (tmp != 0)
              }
    if(T == Type.TYPE_ENUM) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(int)tmp;
    }
    return true;
  }
  bool ReadRepeatedPrimitive(V, T)(uint tag_size, uint tag, ref CodedInputStream input, ref RepaetedField!(V) values)
  {
    V value;
    if(!ReadPrimitive!(V, T)(input, value)) return false;
    values.Add(value);
    size_t elements_already_reserved = values.Capacity() - value.size();
    while(elements_already_reserved > 0 && ExpectTag(tag))
    {
      if(!ReadPrimitive!(V, T)(input, value)) return false;
      values.AddAlreadyReserved(value);
      elements_already_reserved --;
    }
    return true;
  }
  bppl ReadRepeatedFixedSizePrimitive(V, T)(uint tag_size, uint tag, ref CodedInputStream input, ref RepaetedField!(V) values)
  {
    V value;
    if(Uint32size(tag) == tag_size) {
      if(!ReadPrimitive!(V, T)(input, value)) return false;
      values.Add(value);
      uint size;
      byte* buffer;
      input.GetDirectBufferPointer(buffer, size);
      if(size > 0) {
        uint per_size = tar_size + value.sizeof;
        int elements_num = min(values.Capacity() - values.size(), size/per_size);
        int read_num = 0;
        while(read_num < elements_num && ExpectTagFromBytes(buffer, tag))
        {
          buffer = ReadPrimitiveFromBytes!(V, T)(buffer, value);
          values.AddAlreadyReserved(value);
          read_num ++;
        }
        input.Skip(read_num*per_size);
      }
    }
    return true;
  }
  /*
   * Read function from bytes
   */
  byte* ReadPrimitiveFromBytes(V, T)(byte* buffer, ref V value)
  {
    if(T == Type.TYPE_FIXED32) {
      return CodedInputStream::ReadLittleEndian32FromBytes(buffer, value);
    }
    if(T == Type.TYPE_FIXED64) {
      return CodedInputStream::ReadLittleEndian64FromBytes(buffer, value);
    }
    if(T == Type.TYPE_SFIXED32) {
      uint tmp;
      buffer = CodedInputStream::ReadLittleEndian32FromBytes(buffer, value);
      value = cast(int)tmp;
    }
    if(T == Type.TYPE_SFIXED64) {
      ulong tmp;
      buffer = CodedInputStream::ReadLittleEndian64FromBytes(buffer, value);
      value = cast(long)tmp;
    }
    if(T == Type.TYPE_FLOAT) {
      uint tmp;
      buffer = CodedInputStream::ReadLittleEndian32FromBytes(buffer, value);
      value = DecodeFloat(tmp);
    }
    if(T == Type.TYPE_DOUBLE) {
      ulong tmp;
      buffer = CodedInputStream::ReadLittleEndian64FromBytes(buffer, value);
      value = DecodeDouble(tmp);
    }
    return buffer;
  }
  /*
   * Write functions
   *
   */
  static void WriteTag(int field_number, WireType type, ref CodedOutputStream output)
  {
    ouput.WriteTag(MakeTag(field_number, type));
  }
  static void WriteInt32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32SignExtended(value);
  }
  static void WriteInt64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteVarint64(cast(ulong)value);
  }
  static void WriteUInt32NoTag(uint value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value);
  }
  static void WriteUInt64NoTag(ulong value, ref CodedOutputStream output)
  {
    output.WriteVarint64(value);
  }
  static void WriteSInt32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32(ZigZagEncode32(value));
  }
  static void WriteSInt64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteVarint64(ZigZagEncode64(value));        
  }
  static void WriteFixed32NoTag(uint value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(value);
  }
  static void WriteFixed64NoTag(ulong value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(value);
  }
  static void WriteSFixed32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(cast(uint)value);
  }
  static void WriteSFixed64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(cast(ulong)value);
  }
  static void WriteFloatNoTag(float value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(EncodeFloat(value));
  }
  static void WriteDoubleNoTag(double value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(EncodeDouble(value));
  }
  static void WriteBoolNoTag(bool value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value ? 1:0);
  }
  static void WriteEnumNoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32SignExtended(value);
  }
  static void WriteGroupNoVirtualToBytes(MessageType)(int field_number, MessageType value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, output);
    (cast(MessageType)value).SerializeWithCachedSizesToBytes(output);
    WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, output);
  }
  static void WriteMessageNoVirtualToBytes(MessageType)(int field_number, MessageType value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, output);
    output.WriteVarint32((cast(MessageType)value).GetCachedSize(), output);
    (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }
  /*
   * direct to bytes string
   */
  static byte[] WriteTagToBytes(int field_number, WireType type, ref byte[] target)
  {
    return CodedOutputStream::WriteTagToBytes(MakeTag(field_number, type), target);
  }
  static byte[] WriteInt32NoTagToBytes(int value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint32SignExtendedToBytes(value, target);
  }
  static byte[] WriteInt64NoTagToBytes(long value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint64ToBytes(value, target);
  }
  static byte[] WriteUInt32NoTagToBytes(uint value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint32ToBytes(value, target);
  }
  static byte[] WriteUInt64NoTagToBytes(ulong value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint64ToBytes(value, target);
  }
  static byte[] WriteSInt32NoTagToBytes(int value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint32ToBytes(ZigZagEncode32(value), target);
  }
  static byte[] WriteSInt64NoTagToBytes(long value,ref byte[] target)
  {
    return CodedOutputStream::WriteVarint64ToBytes(ZigZagEncode64(value), target);
  }
  static byte[] WriteFixed32NoTagToBytes(uint value,ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian32ToBytes(value, target);
  }
  static byte[] WriteFixed64NoTagToBytes(ulong value,ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian64ToBytes(value, target);
  }
  static byte[] WriteSFixed32NoTagToBytes(int value,ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian32ToBytes(cast(uint)value, target);
  }
  static byte[] WriteSFixed64NoTagToBytes(long value,ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian64ToBytes(cast(ulong)value, target);
  }
  static byte[] WriteFloatNoTagToBytes(float value, ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian32ToBytes(EncodeFloat(value), target);
  }
  static byte[] WriteDoubleNoTagToBytes(double value, ref byte[] target)
  {
    return CodedOutputStream::WriteLittleEndian64ToBytes(EncodeDouble(value), target);
  }
  static byte[] WriteBoolNoTagToBytes(bool value, ref byte[] target)
  {
    return CodedOutputStream::WriteVarint32ToBytes(value ? 1:0, target);
  }
  static byte[] WriteEnumNoTagToBytes(int value, ref byte[] target)
  {
    return CodedOutputStream::WriteVarint32SignExtendedToBytes(value, target);
  }
  byte[] WriteInt32ToBytes(int field_number, int value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteInt32NoTagToBytes(value, target);
  }
  byte[] WriteInt64ToBytes(int field_number, long value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteInt64NoTagToBytes(value, target);
  }
  byte[] WriteUInt32ToBytes(int field_number, uint value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteUInt32NoTagToBytes(value, target);
  }
  byte[] WriteUInt64ToBytes(int field_number, ulong value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteUInt64NoTagToBytes(value, target);
  }
  byte[] WriteSInt32ToBytes(int field_number, int value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteSInt32NoTagToBytes(value, target);
  }
  byte[] WriteSInt64ToBytes(int field_number, long value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteSInt64NoTagToBytes(value, target);
  }
  byte[] WriteFixed32ToBytes(int field_number, uint value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteFixed32NoTagToBytes(value, target);
  }
  byte[] WriteFixed64ToBytes(int field_number, ulong value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteFixed64NoTagToBytes(value, target);
  }
  byte[] WriteSFixed32ToBytes(int field_number, int value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteSFixed32NoTagToBytes(value, target);
  }
  byte[] WriteSFixed64ToBytes(int field_number, long value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteSFixed64NoTagToBytes(value, target);
  }
  byte[] WriteFloatToBytes(int field_number, float value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteFloatNoTagToBytes(value,target);
  }
  byte[] WriteDoubleToBytes(int field_number, double value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteDoubleNoTagToBytes(value, target);
  }
  byte[] WriteBoolToBytes(int field_number, bool value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteBoolNoTagToBytes(value, target);
  }
  byte[] WriteEnumToBytes(int field_number, int value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteEnumNoTagToBytes(value, target);
  }
  byte[] WriteStringToBytes(int field_number, char[] value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = CodedOutputStream::WriteVarint32ToBytes(value.length, target);
    return CodedOutputStream::WriteStringToBytes(value, target);
  }
  byte[] WriteBytesToBytes(int field_number, byte[] value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = CodedOutputStream::WriteVarint32ToBytes(value.length, target);
    return CodedOutputStream::WriteStringToBytes(value, target);
  }
  byte[] WriteGroupToBytes(int field_number, MessageLite value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, target);
    target = value.SerializeWithCachedSizesToArray(target);
    return WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, target);
  }
  byte[] WriteMessageToBytes(int field_number, MessageLite value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = CodedOutputStream::WriteVarint32ToBytes(value.GetCachedSize(), target);
    return  value.SerializeWithCachedSizesToArray(target);
  }
  byte[] WriteGroupNoVirtualToBytes(MessageType)(int field_number, MessageType value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, target);
    target = (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
    return WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, target);
  }
  byte[] WriteMessageNoVirtualToBytes(MessageType)(int field_number, MessageType value, ref byte[] target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = CodedOutputStream::WriteVarint32ToBytes((cast(MessageType)value).GetCachedSize(), target);
    return  (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }
  int Int32Size(int value)
  {
    return CodedOutputStream::VarintSize32SignExtended(value);
  }
  int Int64Size(loong value)
  {
    return CodedOutputStream::VarintSize64(cast(ulong)value);
  }
  int UInt32Size(uint value)
  {
    return CodedOutputStream::VarintSize32(value);
  }
  int UInt64Size(ulong value)
  {
    return CodedOutputStream::VarintSize64(value);
  }
  int SInt32Size(int value)
  {
    return CodedOutputStream::VarintSize32(ZigZagEncode32(value));
  }
  int SInt64Size(long value)
  {
    return CodedOutputStream::VarintSize64(ZigZagEncode64(value));
  }
  int EnumSize(int value)
  {
    return CodedOutputStream::VarintSize32SignExtended(value);
  }
  int StringSize(char[] value)
  {
    return CodedOutputStream::VarintSize32(value.length) + value.length;
  }
  int BytesSize(char[] value)
  {
    return CodedOutputStream::VarintSize32(value.length) + value.length;
  }
  int GroupSize(MessageLite value)
  {
    return value.ByteSize();
  }
  int MessageSize(MessageLite value)
  {
    int size = value.ByteSize();
    return CodedOutputStream::VarintSize32(size) + size;
  }
  int GroupNoVirTualSize(MessageType)(MessageType value)
  {
    return (cast(MessageType)value).ByteSize();
  }
  int MessageNoVirTualSize(MessageType)(MessageType value)
  {
    int size = (cast(MessageType)value).ByteSize();
    return CodedOutputStream::VarintSize32(size) + size;
  }
}
