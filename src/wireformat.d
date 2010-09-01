private import tango.io.Stdout;

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
enum Type
{
    TYPE_DOUBLE         = 1,   // double, exactly eight bytes on the wire.
        TYPE_FLOAT          = 2,   // float, exactly four bytes on the wire.
        TYPE_INT64          = 3,   // int64, varint on the wire.  Negative numbers
        // take 10 bytes.  Use TYPE_SINT64 if negative
        // values are likely.
        TYPE_UINT64         = 4,   // uint64, varint on the wire.
        TYPE_INT32          = 5,   // int32, varint on the wire.  Negative numbers
        // take 10 bytes.  Use TYPE_SINT32 if negative
        // values are likely.
        TYPE_FIXED64        = 6,   // uint64, exactly eight bytes on the wire.
        TYPE_FIXED32        = 7,   // uint32, exactly four bytes on the wire.
        TYPE_BOOL           = 8,   // bool, varint on the wire.
        TYPE_STRING         = 9,   // UTF-8 text.
        TYPE_GROUP          = 10,  // Tag-delimited message.  Deprecated.
        TYPE_MESSAGE        = 11,  // Length-delimited message.
        
        TYPE_BYTES          = 12,  // Arbitrary byte array.
        TYPE_UINT32         = 13,  // uint32, varint on the wire
        TYPE_ENUM           = 14,  // Enum, varint on the wire
        TYPE_SFIXED32       = 15,  // int32, exactly four bytes on the wire
        TYPE_SFIXED64       = 16,  // int64, exactly eight bytes on the wire
        TYPE_SINT32         = 17,  // int32, ZigZag-encoded varint on the wire
        TYPE_SINT64         = 18,  // int64, ZigZag-encoded varint on the wire

        MAX_TYPE            = 19,  // Constant useful for defining lookup tables
        // indexed by Type.
        }
class WireFormat
{
    enum WireType { 
        WIRETYPE_VARINT           = 0,
            WIRETYPE_FIXED64          = 1,
            WIRETYPE_LENGTH_DELIMITED = 2,
            WIRETYPE_START_GROUP      = 3,
            WIRETYPE_END_GROUP        = 4,
            WIRETYPE_FIXED32          = 5,
            };
    static const WireType[Type] WireTypeForFieldType;
    // Number of bits in a tag which identify the wire type.
    static const int TagTypeBits = 3;
    // Mask for those bits.
    static const uint TagTypeMask = (1 << TagTypeBits) - 1;
    static this()
    {
        Type[] tp = [Type.TYPE_INT64,Type.TYPE_INT32,Type.TYPE_UINT64,Type.TYPE_UINT32,Type.TYPE_SINT64,Type.TYPE_SINT32,Type.TYPE_ENUM,Type.TYPE_BOOL,Type.TYPE_SFIXED64,Type.TYPE_FIXED64,Type.TYPE_DOUBLE,Type.TYPE_SFIXED32,Type.TYPE_FIXED32,Type.TYPE_FLOAT,Type.TYPE_STRING,Type.TYPE_MESSAGE,Type.TYPE_BYTES,Type.TYPE_GROUP,];
        foreach(Type t;tp)
        {
            switch(t)
            {
            case Type.TYPE_INT64:
            case Type.TYPE_INT32:
            case Type.TYPE_UINT64:
            case Type.TYPE_UINT32:
            case Type.TYPE_SINT64:
            case Type.TYPE_SINT32:
            case Type.TYPE_ENUM:
            case Type.TYPE_BOOL:
                WireTypeForFieldType[t] = WireType.WIRETYPE_VARINT;
                break;
            case Type.TYPE_SFIXED64:
            case Type.TYPE_FIXED64:
            case Type.TYPE_DOUBLE:
                WireTypeForFieldType[t] = WireType.WIRETYPE_FIXED64;
                break;
            case Type.TYPE_SFIXED32:
            case Type.TYPE_FIXED32:
            case Type.TYPE_FLOAT:
                WireTypeForFieldType[t] = WireType.WIRETYPE_FIXED32;
                break;
            case Type.TYPE_STRING:
            case Type.TYPE_MESSAGE:
            case Type.TYPE_BYTES:
                WireTypeForFieldType[t] = WireType.WIRETYPE_LENGTH_DELIMITED;
                break;
            case Type.TYPE_GROUP:
                WireTypeForFieldType[t] = WireType.WIRETYPE_START_GROUP;
                break;
            }
        }
    }
    uint ZigZagEncode32(int n)
    {
        return (n << 1) ^ (n >> 31);
    }
    ulong ZigZagEncode64(long n)
    {
        return (n << 1) ^ (n >> 63);
    }
    int ZigZagDecode32(uint n)
    {
        return (n >> 1)^-cast(int)( n & 1);
    }
    long ZigZagDecode64(ulong n)
    {
        return (n >> 1)^-cast(long)( n & 1);
    }
    uint EncodeFloat(float value)
    {
        union U {float f; uint i;};
        U u;
        u.f = value;
        return u.i;
    }
    float DecodeFloat(uint value)
    {
        union U {float f; uint i;};
        U u;
        u.i = value;
        return u.f;
    }
    ulong EncodeDouble(double value)
    {
        union U {double f; ulong i;};
        U u;
        u.f = value;
        return u.i;
    }
    double DecodeDouble(ulong value)
    {
        union U {double f; ulong i;};
        U u;
        u.i = value;
        return u.f;
    }
    byte[] EncodeBuf(uint a)
    {
        byte[] rst;
        rst ~= a&0x7f;
        a = a>>7;
        while(a)
        {
            rst[rst.length-1] |= 0x80;
            rst ~= a&0x7f;
            a >>= 7;
        }
        return rst;
    }
    byte[] EncodeBuf(ulong a)
    {
        byte[] rst;
        rst ~= a&0x7f;
        a = a>>7;
        while(a)
        {
            rst[rst.length-1] |= 0x80;
            rst ~= a&0x7f;
            a >>= 7;
        }
        return rst;
    }
    T Decode(T)(byte[] a)
    {
        T rst;
        for(int i = 0;i <a.length ; i++)
        {
            rst |= (a[i]&0x7f) << (7*i);
        }
        return rst;
    }
    uint MakeTag(int field_number,byte wire_type)
    {
        return (field_number << TagTypeBits) | wire_type;
    }
    /*uint MakeTag(FieldDescriptor field)
      {
      return MakeTag(field.number(), WireTypeForFieldType[field.type()]);
      }*/
    int GetTagFieldNumber(uint tag)
    {
        return cast(int)(tag >> TagTypeBits);
    }
    WireType GetTagWireType(uint tag)
    {
        return cast(WireType)(tag & TagTypeMask);
    }
    WireType GetWireTypeForFieldType(Type tname)
    {
        return WireTypeForFieldType[tname];
    }
    void SkipField(ref byte[] inputstream,uint tag,ref byte[] unknow_field )
    {
        uint off_size;
        switch(GetTagWireType(tag))
        {
        case WireType.WIRETYPE_VARINT:
            {
                off_size = GetVarintLength(inputstream);
                break;
            }
        case WireType.WIRETYPE_FIXED64:
            off_size = 8;
            break;
        case WireType.WIRETYPE_LENGTH_DELIMITED:
            {
                int size = GetVarintLength(inputstream);
                uint len = Decode!(uint)(inputstream[0..size]);
                off_size = len +size;
                break;
            }
        case WireType.WIRETYPE_START_GROUP:
        case WireType.WIRETYPE_END_GROUP:
            off_size = 1;
            break;
        case WireType.WIRETYPE_FIXED32:
            off_size = 4;
            break;
        }
        unknow_field ~= inputstream[0..off_size];
        inputstream = inputstream[off_size..length];
    }
    byte[] toByteString(string ulimit,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(WireTypeForFieldType[field_type] != WireType.WIRETYPE_LENGTH_DELIMITED)
            throw new Exception("Type is not length delimited");
        return EncodeBuf(tag)~toByteString(cast(byte[])ulimit);
    }
    byte[] toByteString(byte[] ulimit,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(WireTypeForFieldType[field_type] != WireType.WIRETYPE_LENGTH_DELIMITED)
            throw new Exception("Type is not length delimited");
        return EncodeBuf(tag)~toByteString(ulimit);
    }
    byte[] toByteString(byte[] ulimit)
    {
        byte[] rst;
        rst ~= EncodeBuf(ulimit.length)~cast(byte[])ulimit;
        return rst;
    }
    byte[] toPackByteString(string[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(WireTypeForFieldType[field_type] != WireType.WIRETYPE_LENGTH_DELIMITED)
            throw new Exception("Type is not length delimited");
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= toByteString(cast(byte[])value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toPackByteString(byte[][] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(WireTypeForFieldType[field_type] != WireType.WIRETYPE_LENGTH_DELIMITED)
            throw new Exception("Type is not length delimited");
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= toByteString(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toPackByteString(Message[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(WireTypeForFieldType[field_type] != WireType.WIRETYPE_LENGTH_DELIMITED)
            throw new Exception("Type is not length delimited");
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= toByteString(value[i].Serialize());
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(bool value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        return  EncodeBuf(tag)~toVarint((value?1:0),field_number,field_type);
    }
    byte[] toPackVarint(bool[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= EncodeBuf(cast(uint)(value[i]?1:0));
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(int value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(field_type == Type.TYPE_INT32)
            return EncodeBuf(tag) ~ EncodeBuf(cast(uint)value);
        if(field_type == Type.TYPE_SINT32)
            return EncodeBuf(tag) ~ EncodeBuf(ZigZagEncode32(value));
        if(field_type == Type.TYPE_SFIXED32)
            return EncodeBuf(tag) ~ toFixed!(int)(value);
    }
    byte[] toPackVarint(int[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            if(field_type == Type.TYPE_INT32)
                rst ~= EncodeBuf(cast(uint)value[i]);
            if(field_type == Type.TYPE_SINT32)
                rst ~= EncodeBuf(ZigZagEncode32(value[i]));
            if(field_type == Type.TYPE_SFIXED32)
                rst ~= toFixed!(int)(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(uint value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(field_type == Type.TYPE_FIXED32)
            return EncodeBuf(tag) ~ toFixed!(uint)(value);
        if(field_type == Type.TYPE_UINT32)
            return  EncodeBuf(tag) ~ EncodeBuf(value);
    }
    byte[] toPackVarint(uint[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            if(field_type == Type.TYPE_FIXED32)
                rst ~= toFixed!(uint)(value[i]);
            if(field_type == Type.TYPE_UINT32)
                rst ~= EncodeBuf(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(long value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(field_type == Type.TYPE_INT64)
            return EncodeBuf(tag) ~ EncodeBuf(cast(uint)value);
        if(field_type == Type.TYPE_SFIXED64)
            return EncodeBuf(tag) ~ toFixed!(long)(value);
        if(field_type == Type.TYPE_SINT64)
            return EncodeBuf(tag) ~ EncodeBuf(ZigZagEncode64(value));
    }
    byte[] toPackVarint(long[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            if(field_type == Type.TYPE_INT64)
                rst ~= EncodeBuf(cast(ulong)value[i]);
            if(field_type == Type.TYPE_SINT64)
                rst ~= EncodeBuf(ZigZagEncode64(value[i]));
            if(field_type == Type.TYPE_SFIXED64)
                rst ~= toFixed!(long)(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(ulong value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        if(field_type == Type.TYPE_FIXED64)
            return EncodeBuf(tag)~toFixed!(ulong)(value);
        if(field_type == Type.TYPE_UINT64)
            return EncodeBuf(tag)~EncodeBuf(value);
    }
    byte[] toPackVarint(ulong[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            if(field_type == Type.TYPE_FIXED64)
                rst ~= toFixed!(ulong)(value[i]);
            if(field_type == Type.TYPE_UINT64)
                rst ~= EncodeBuf(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(float value,int field_number, Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        return EncodeBuf(tag) ~ toFixed!(float)(value);
    }
    byte[] toPackVarint(float[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= toFixed!(float)(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toVarint(double value,int field_number, Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        return EncodeBuf(tag)~toFixed!(double)(value);
    }
    byte[] toPackVarint(double[] value,int field_number,Type field_type)
    {
        uint tag;
        tag = MakeTag(field_number,WireTypeForFieldType[field_type]);
        byte[] rst;
        for(int i = 0;i<value.length;i++)
        {
            rst ~= toFixed!(double)(value[i]);
        }
        return EncodeBuf(tag)~EncodeBuf(cast(uint)rst.length)~rst;
    }
    byte[] toFixed(T)(T value)
    {
        byte[] rst;
        rst = (cast(byte*)&value)[0..T.sizeof].dup;
        version (BigEndian) 
        {
            rst.reverse;
        }
        return rst;
    }
    T fromFixed(T)(byte[] input)
    {
        T rst;
        if((input.length !=4)&&(input.length !=8))
            throw new Exception("covert error in fixed type");
        version (BigEndian) 
        {
            input.reverse;
        }
        (cast(byte*)&rst)[0..T.sizeof] = input[0..T.sizeof];
        return rst;
    }
    uint GetTag(ref byte[] input)
    {
        uint size = GetVarintLength(input);
        byte[] tmp = input[0..size];
        input = input[size..length];
        return Decode!(uint)(tmp);
    }
    byte[] GetFieldValue(ref byte[] inputstream,uint tag)
    {
        uint off_size;
        byte[] rst;
        switch(GetTagWireType(tag))
        {
        case WireType.WIRETYPE_VARINT:
            {
                off_size = GetVarintLength(inputstream);
                break;
            }
        case WireType.WIRETYPE_FIXED64:
            {
                off_size = 8;
                break;
            }
        case WireType.WIRETYPE_LENGTH_DELIMITED:
            {
                int size = GetVarintLength(inputstream);
                uint len = Decode!(uint)(inputstream[0..size]);
                off_size = len +size;
                rst = inputstream[size..off_size];
                break;
            }
        case WireType.WIRETYPE_START_GROUP:
        case WireType.WIRETYPE_END_GROUP:
            {
                off_size = 1;
                break;
            }
        case WireType.WIRETYPE_FIXED32:
            {
                off_size = 4;
                break;
            }
        }
        if(rst is null)
            rst = inputstream[0..off_size];
        inputstream = inputstream[off_size..length];
        return rst;
    }
    /*bool SerializeWithCachedSizes(Message message, int size, byte[] codedoutput)
      {
      }
      bool ParseAndMergePartial(byte[] codedinput,Message message )
      {
      }
      bool SerializeUnknownFields(UnknownFieldSet[] unknow_field,byte[] codedoutput)
      {
      }
      bool SerializeUnknownMessageSetItems(UnknownFieldSet[] unknown_fields,byte[] codedoutput)
      {
      }
      int ComputeUnknownFieldsSize(UnknownFieldSet[] unknown_fields)
      {
      }
      int ComputeUnknownMessageSetItemsSize(UnknownFieldSet[] unknown_fields)
      {
      }*/
    int GetVarintLength(byte[] input)
    {
        int i;
        for(i = 0; i< input.length; i++)
        {
            if(!(input[i]>>7))
                break;
        }
        i +=1;
        return i;
    }
}

class Message : WireFormat
{
    byte[] unknown_fields()
    {
        return _unknown_fields;
    }
    byte[] mutable_unknown_fields()
    {
        return _unknown_fields.dup;
    }
    int GetCachedSize()
    {
        return _cached_size_;
    }
    void SetCachedSize(int size)
    {
        _cached_size_ = size; 
    }
    byte[] _unknown_fields;
    byte[] Serialize()
    {
        return _unknown_fields;
    }
    Message Deserialize(byte[] input)
    {
        return new Message(input);
    }
    this(ref byte[] input)
    {   
    }
	this()
	{
	}
 private:
    int _cached_size_;
}
