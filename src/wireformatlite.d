private import tango.io.Stdout;
private import prototype;
private import io;
private import messagelite;


private alias char[] string;

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
  int GetTagFieldNumber(uint tag)
  {
    return cast(int) (tag >> TagTypeBits);
  }
  WireType GetTagWireType(uint tag)
  {
    return cast(WireType) (tag & TagTypeMask);
  }
  bool ReadPrimitive(V)(CodedInputStream input, ref V value, FieldType type)
  {
    if(type == FieldType.TYPE_INT32) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_INT64) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_UINT32) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_UINT64) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_SINT32) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = ZigZagDecode32(tmp);
    }
    if(type == FieldType.TYPE_SINT64) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = ZigZagDecode64(tmp);
    }
    if(type == FieldType.TYPE_FIXED32) {
      uint tmp;
      if(!input.ReadLittleEndian32(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_FIXED64) {
      ulong tmp;
      if(!input.ReadLittleEndian64(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_SFIXED32) {
      uint tmp;
      if(!input.ReadLittleEndian32(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_SFIXED64) {
      ulong tmp;
      if(!input.ReadLittleEndian64(tmp)) return false;
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_FLOAT) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(V)DecodeFloat(tmp);
    }
    if(type == FieldType.TYPE_DOUBLE) {
      ulong tmp;
      if(!input.ReadVarint64(tmp)) return false;
      value = cast(V)DecodeDouble(tmp);
    }
    if(type == FieldType.TYPE_BOOL) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = (tmp != 0);
    }
    if(type == FieldType.TYPE_ENUM) {
      uint tmp;
      if(!input.ReadVarint32(tmp)) return false;
      value = cast(V)tmp;
    }
    return true;
  }
  /*
  bool ReadRepeatedFixedSizePrimitive(V, T)(uint tag_size, uint tag, ref CodedInputStream input, ref V[] values)
  {
   
      V value;
      if(Uint32size(tag) == tag_size) {
      if(!ReadPrimitive!(V, T)(input, value)) return false;
      values ~= value;
      uint size;
      byte* buffer;
      input.GetDirectBufferPointer(buffer, size);
      if(size > 0) {
        uint per_size = tag_size + value.sizeof;
        int elements_num = size/per_size;
        int read_num = 0;
        while(read_num < elements_num && ExpectTagFromBytes(buffer, tag))
        {
          buffer = ReadPrimitiveFromBytes!(V, T)(buffer, value);
          values ~= value;
          read_num ++;
        }
        input.Skip(read_num*per_size);
      }
    }
    return true;
  }
  */
  
  /*
   * Read function from bytes
   */
  byte* ReadPrimitiveFromBytes(V)(byte* buffer, ref V value, FieldType type)
  {
    if(type == FieldType.TYPE_FIXED32) {
      return instream.ReadLittleEndian32FromBytes(buffer, value);
    }
    if(type == FieldType.TYPE_FIXED64) {
      return instream.ReadLittleEndian64FromBytes(buffer, value);
    }
    if(type == FieldType.TYPE_SFIXED32) {
      uint tmp;
      buffer = instream.ReadLittleEndian32FromBytes(buffer, value);
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_SFIXED64) {
      ulong tmp;
      buffer = instream.ReadLittleEndian64FromBytes(buffer, value);
      value = cast(V)tmp;
    }
    if(type == FieldType.TYPE_FLOAT) {
      uint tmp;
      buffer = instream.ReadLittleEndian32FromBytes(buffer, value);
      value = DecodeFloat(tmp);
    }
    if(type == FieldType.TYPE_DOUBLE) {
      ulong tmp;
      buffer = instream.ReadLittleEndian64FromBytes(buffer, value);
      value = DecodeDouble(tmp);
    }
    return buffer;
  }
  /*
   * Write functions
   *
   */
  void WriteTag(int field_number, WireType type, ref CodedOutputStream output)
  {
    output.WriteTag(MakeTag(field_number, type));
  }
  void WriteInt32(int field_number, int value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint32SignExtended(value);
  }
  void WriteInt64(int field_number, long value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint64(cast(ulong)value);
  }
  void WriteUInt32(int field_number, uint value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint32(value);
  }
  void WriteUInt64(int field_number, ulong value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint64(value);
  }
  void WriteSInt32(int field_number, int value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint32(ZigZagEncode32(value));
  }
  void WriteSInt64(int field_number, long value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint64(ZigZagEncode64(value));        
  }
  void WriteFixed32(int field_number, uint value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian32(value);
  }
  void WriteFixed64(int field_number, ulong value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian64(value);
  }
  void WriteSFixed32(int field_number, int value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian32(cast(uint)value);
  }
  void WriteSFixed64(int field_number, long value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian64(cast(ulong)value);
  }
  void WriteFloat(int field_number, float value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian32(EncodeFloat(value));
  }
  void WriteDouble(int field_number, double value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteLittleEndian64(EncodeDouble(value));
  }
  void WriteBool(int field_number, bool value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint32(value ? 1:0);
  }
  void WriteEnum(int field_number, int value, ref CodedOutputStream output)
  {
    WriteTag(field_number, WireType.WIRETYPE_VARINT, output);
    output.WriteVarint32SignExtended(value);
  }
  void WriteString(int field_number, char[] value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, output);
    output.WriteVarint32(value.length, output);
    output.WriteString(value);
  }
  void WriteBytes(int field_number, byte[] value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, output);
    output.WriteVarint32(value.length, output);
    output.WriteRaw(value);
  }
  void WriteGroup(int field_number, MessageLite value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, output);
    value.SerializeWithCachedSizes(output);
    WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, output);
  }
  void WriteMessage(int field_number, MessageLite value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, output);
    output.WriteVarint32(value.GetCachedSize(), output);
    (cast(MessageType)value).SerializeWithCachedSizes(output);
  }
  void WriteGroupNoVirtual(MessageType)(int field_number, MessageType value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, output);
    (cast(MessageType)value).SerializeWithCachedSizes(output);
    WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, output);
  }
  void WriteMessageNoVirtual(MessageType)(int field_number, MessageType value, ref CodedOutputStream output)
  {
    WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, output);
    output.WriteVarint32((cast(MessageType)value).GetCachedSize(), output);
    (cast(MessageType)value).SerializeWithCachedSizes(output);
  }
  /*
   * write values without tags, functions for codedoutoputstream
   */
  void WriteInt32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32SignExtended(value);
  }
  void WriteInt64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteVarint64(cast(ulong)value);
  }
  void WriteUInt32NoTag(uint value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value);
  }
  void WriteUInt64NoTag(ulong value, ref CodedOutputStream output)
  {
    output.WriteVarint64(value);
  }
  void WriteSInt32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32(ZigZagEncode32(value));
  }
  void WriteSInt64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteVarint64(ZigZagEncode64(value));        
  }
  void WriteFixed32NoTag(uint value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(value);
  }
  void WriteFixed64NoTag(ulong value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(value);
  }
  void WriteSFixed32NoTag(int value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(cast(uint)value);
  }
  void WriteSFixed64NoTag(long value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(cast(ulong)value);
  }
  void WriteFloatNoTag(float value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian32(EncodeFloat(value));
  }
  void WriteDoubleNoTag(double value, ref CodedOutputStream output)
  {
    output.WriteLittleEndian64(EncodeDouble(value));
  }
  void WriteBoolNoTag(bool value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value ? 1:0);
  }
  void WriteEnumNoTag(int value, ref CodedOutputStream output)
  {
    output.WriteVarint32SignExtended(value);
  }
  void WriteStringNoTag(char[] value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value.length, output);
    output.WriteString(value);
  }
  void WriteBytesNoTag(byte[] value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value.length, output);
    output.WriteRaw(value);
  }
  void WriteGroupNoTag(MessageLite value, ref CodedOutputStream output)
  {
    value.SerializeWithCachedSizesToBytes(output);
  }
  void WriteMessageNoTag(MessageLite value, ref CodedOutputStream output)
  {
    output.WriteVarint32(value.GetCachedSize(), output);
    value.SerializeWithCachedSizesToBytes(output);
  }
  void WriteGroupNoVirtualNoTag(MessageType)(MessageType value, ref CodedOutputStream output)
  {
    (cast(MessageType)value).SerializeWithCachedSizesToBytes(output);
  }
  void WriteMessageNoVirtualNoTag(MessageType)(MessageType value, ref CodedOutputStream output)
  {
    output.WriteVarint32((cast(MessageType)value).GetCachedSize(), output);
    (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }
  /*
   * direct to bytes string
   */
  byte* WriteTagToBytes(int field_number, WireType type, byte* target)
  {
    return this.outstream.WriteTagToBytes(MakeTag(field_number, type), target);
  } 
  byte* WriteInt32NoTagToBytes(int value,byte* target)
  {
    return this.outstream.WriteVarint32SignExtendedToBytes(value, target);
  }
  byte* WriteInt64NoTagToBytes(long value,byte* target)
  {
    return this.outstream.WriteVarint64ToBytes(value, target);
  }
  byte* WriteUInt32NoTagToBytes(uint value,byte* target)
  {
    return this.outstream.WriteVarint32ToBytes(value, target);
  }
  byte* WriteUInt64NoTagToBytes(ulong value,byte* target)
  {
    return this.outstream.WriteVarint64ToBytes(value, target);
  }
  byte* WriteSInt32NoTagToBytes(int value,byte* target)
  {
    return this.outstream.WriteVarint32ToBytes(ZigZagEncode32(value), target);
  }
  byte* WriteSInt64NoTagToBytes(long value,byte* target)
  {
    return this.outstream.WriteVarint64ToBytes(ZigZagEncode64(value), target);
  }
  byte* WriteFixed32NoTagToBytes(uint value,byte* target)
  {
    return this.outstream.WriteLittleEndian32ToBytes(value, target);
  }
  byte* WriteFixed64NoTagToBytes(ulong value,byte* target)
  {
    return this.outstream.WriteLittleEndian64ToBytes(value, target);
  }
  byte* WriteSFixed32NoTagToBytes(int value,byte* target)
  {
    return this.outstream.WriteLittleEndian32ToBytes(cast(uint)value, target);
  }
  byte* WriteSFixed64NoTagToBytes(long value,byte* target)
  {
    return this.outstream.WriteLittleEndian64ToBytes(cast(ulong)value, target);
  }
  byte* WriteFloatNoTagToBytes(float value, byte* target)
  {
    return this.outstream.WriteLittleEndian32ToBytes(EncodeFloat(value), target);
  }
  byte* WriteDoubleNoTagToBytes(double value, byte* target)
  {
    return this.outstream.WriteLittleEndian64ToBytes(EncodeDouble(value), target);
  }
  byte* WriteBoolNoTagToBytes(bool value, byte* target)
  {
    return this.outstream.WriteVarint32ToBytes(value ? 1:0, target);
  }
  byte* WriteEnumNoTagToBytes(int value, byte* target)
  {
    return this.outstream.WriteVarint32SignExtendedToBytes(value, target);
  }
  byte* WriteGroupNoTagToBytes(MessageLite value, byte* target)
  {
    return value.SerializeWithCachedSizesToBytes(target);
  }
  byte* WriteMessageNoTagToBytes(MessageLite value, byte* target)
  {
    target = outstream.WriteVarint32ToBytes(value.GetCachedSize(), target);
    return  value.SerializeWithCachedSizesToBytes(target);
  }
  byte* WriteGroupNoVirtualNoTagToBytes(MessageType)(MessageType value, byte* target)
  {
    return (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }
  byte* WriteMessageNoVirtualNoTagToBytes(MessageType)(MessageType value, byte* target)
  {
    target = outstream.WriteVarint32ToBytes((cast(MessageType)value).GetCachedSize(), target);
    return  (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }

  /*
   * with tags
   */
  byte* WriteInt32ToBytes(int field_number, int value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteInt32NoTagToBytes(value, target);
  }
  byte* WriteInt64ToBytes(int field_number, long value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteInt64NoTagToBytes(value, target);
  }
  byte* WriteUInt32ToBytes(int field_number, uint value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteUInt32NoTagToBytes(value, target);
  }
  byte* WriteUInt64ToBytes(int field_number, ulong value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteUInt64NoTagToBytes(value, target);
  }
  byte* WriteSInt32ToBytes(int field_number, int value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteSInt32NoTagToBytes(value, target);
  }
  byte* WriteSInt64ToBytes(int field_number, long value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteSInt64NoTagToBytes(value, target);
  }
  byte* WriteFixed32ToBytes(int field_number, uint value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteFixed32NoTagToBytes(value, target);
  }
  byte* WriteFixed64ToBytes(int field_number, ulong value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteFixed64NoTagToBytes(value, target);
  }
  byte* WriteSFixed32ToBytes(int field_number, int value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteSFixed32NoTagToBytes(value, target);
  }
  byte* WriteSFixed64ToBytes(int field_number, long value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteSFixed64NoTagToBytes(value, target);
  }
  byte* WriteFloatToBytes(int field_number, float value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED32, target);
    return WriteFloatNoTagToBytes(value,target);
  }
  byte* WriteDoubleToBytes(int field_number, double value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_FIXED64, target);
    return WriteDoubleNoTagToBytes(value, target);
  }
  byte* WriteBoolToBytes(int field_number, bool value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteBoolNoTagToBytes(value, target);
  }
  byte* WriteEnumToBytes(int field_number, int value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_VARINT, target);
    return WriteEnumNoTagToBytes(value, target);
  }
  byte* WriteStringToBytes(int field_number, char[] value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = outstream.WriteVarint32ToBytes(value.length, target);
    return this.outstream.WriteStringToBytes(value, target);
  }
  byte* WriteBytesToBytes(int field_number, byte[] value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = outstream.WriteVarint32ToBytes(value.length, target);
    return this.outstream.WriteStringToBytes(cast(char[])value, target);
  }
  byte* WriteGroupToBytes(int field_number, MessageLite value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, target);
    target = value.SerializeWithCachedSizesToBytes(target);
    return WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, target);
  }
  byte* WriteMessageToBytes(int field_number, MessageLite value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = outstream.WriteVarint32ToBytes(value.GetCachedSize(), target);
    return  value.SerializeWithCachedSizesToBytes(target);
  }
  byte* WriteGroupNoVirtualToBytes(MessageType)(int field_number, MessageType value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_START_GROUP, target);
    target = (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
    return WriteTagToBytes(field_number, WireType.WIRETYPE_END_GROUP, target);
  }
  byte* WriteMessageNoVirtualToBytes(MessageType)(int field_number, MessageType value, byte* target)
  {
    target = WriteTagToBytes(field_number, WireType.WIRETYPE_LENGTH_DELIMITED, target);
    target = outstream.WriteVarint32ToBytes((cast(MessageType)value).GetCachedSize(), target);
    return  (cast(MessageType)value).SerializeWithCachedSizesToBytes(target);
  }
  uint Int32Size(int value)
  {
    return this.outstream.VarintSize32SignExtended(value);
  }
  uint Int64Size(long value)
  {
    return this.outstream.VarintSize64(cast(ulong)value);
  }
  uint UInt32Size(uint value)
  {
    return this.outstream.VarintSize32(value);
  }
  uint UInt64Size(ulong value)
  {
    return this.outstream.VarintSize64(value);
  }
  uint SInt32Size(int value)
  {
    return this.outstream.VarintSize32(ZigZagEncode32(value));
  }
  uint SInt64Size(long value)
  {
    return this.outstream.VarintSize64(ZigZagEncode64(value));
  }
  uint EnumSize(int value)
  {
    return this.outstream.VarintSize32SignExtended(value);
  }
  uint StringSize(char[] value)
  {
    return this.outstream.VarintSize32(value.length) + value.length;
  }
  uint BytesSize(char[] value)
  {
    return this.outstream.VarintSize32(value.length) + value.length;
  }
  uint GroupSize(MessageLite value)
  {
    return value.ByteSize();
  }
  uint MessageSize(MessageLite value)
  {
    uint size = value.ByteSize();
    return this.outstream.VarintSize32(size) + size;
  }
  uint GroupNoVirTualSize(MessageType)(MessageType value)
  {
    return (cast(MessageType)value).ByteSize();
  }
  uint MessageNoVirTualSize(MessageType)(MessageType value)
  {
    int size = (cast(MessageType)value).ByteSize();
    return this.outstream.VarintSize32(size) + size;
  }
  this()
  {
    outstream = new CodedOutputStream;
    instream = new CodedInputStream;
  }
 private:
  CodedOutputStream *outstream;
  CodedInputStream *instream;
}

debug(UnitTest)
{
  unittest
  {
    WireFormatLite p = new WireFormatLite;
  }
}
