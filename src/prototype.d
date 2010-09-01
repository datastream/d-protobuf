private alias char[] string;

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
enum DType
{
    DTYPE_INT           = 1,   //TYPE_INT32, TYPE_SINT32, TYPE_SFIXED32
        DTYPE_LONG          = 2,   //TYPE_INT64, TYPE_SINT64, TYPE_SFIXED64
        DTYPE_UINT          = 3,   //TYPE_UINT32, TYPE_FIXED32
        DTYPE_ULONG         = 4,   //TYPE_UINT64, TYPE_FIXED64
        DTYPE_DOUBLE        = 5,   //TYPE_DOUBLE
        DTYPE_FLOAT         = 6,   //TYPE_FLOAT
        DTYPE_BOOL          = 7,   //TYPE_BOOL
        DTYPE_ENUM          = 8,   //TYPE_ENUM
        DTYPE_STRING        = 9,   //TYPE_STRING, TYPE_BYTES
        DTYPE_MESSAGE       = 10,  //TYPE_MESSAGE, TYPE_GROUP
        MAX_DTYPE           = 11,  //Constant useful for defining lookup tables indexed by DType
        }
enum Label
{
    LABEL_OPTIONAL      = 1,    // optional
        LABEL_REQUIRED      = 2,    // required
        LABEL_REPEATED      = 3,    // repeated
        MAX_LABEL           = 3,    // Constant useful for defining lookup tables indexed by Label.
        }    
DType d_type(Type field_type)
{
    switch(field_type)
    {
    case Type.TYPE_DOUBLE:
        return DType.DTYPE_DOUBLE;
    case Type.TYPE_FLOAT:
        return DType.DTYPE_FLOAT;
    case Type.TYPE_UINT32:
    case Type.TYPE_FIXED32:
        return DType.DTYPE_UINT;
    case Type.TYPE_INT32:
    case Type.TYPE_SINT32:
    case Type.TYPE_SFIXED32:
        return DType.DTYPE_INT;
    case Type.TYPE_UINT64:
    case Type.TYPE_FIXED64:
        return DType.DTYPE_ULONG;
    case Type.TYPE_INT64:
    case Type.TYPE_SINT64:
    case Type.TYPE_SFIXED64:
        return DType.DTYPE_LONG;
    case Type.TYPE_BYTES:
    case Type.TYPE_STRING:
        return DType.DTYPE_STRING;
    case Type.TYPE_BOOL:
        return DType.DTYPE_BOOL;
    case Type.TYPE_ENUM:
        return DType.DTYPE_ENUM;
    case Type.TYPE_MESSAGE:
    case Type.TYPE_GROUP:
        return DType.DTYPE_MESSAGE;
    default:
        return DType.MAX_DTYPE;
    }
}

Label StringToLable(string label)
{
    switch(label)
    {
    case "repeated":
        return Label.LABEL_REPEATED;
    case "optional":
        return Label.LABEL_OPTIONAL;
    case "required":
        return Label.LABEL_REQUIRED;
    default:
        throw new Exception("Lable error: " ~ label);
    }
}
Type StringToType(string type)
{
    switch(type)
    {
    case "double":
        return Type.TYPE_DOUBLE;
    case "float":
        return Type.TYPE_FLOAT;
    case "int64":
        return Type.TYPE_INT64;
    case "uint64":
        return Type.TYPE_UINT64;
    case "sint64":
        return Type.TYPE_SINT64;
    case "fixed64":
        return Type.TYPE_FIXED64;
    case "sfixed64":
        return Type.TYPE_SFIXED64;
    case "int32":
        return Type.TYPE_INT32;
    case "uint32":
        return Type.TYPE_UINT32;
    case "sint32":
        return Type.TYPE_SINT32;
    case "fixed32":
        return Type.TYPE_FIXED32;
    case "sfixed32":
        return Type.TYPE_SFIXED32;
    case "bool":
        return Type.TYPE_BOOL;
    case "string":
        return Type.TYPE_STRING;
    case "bytes":
        return Type.TYPE_BYTES;
    case "message":
        return Type.TYPE_MESSAGE;
    case "enum":
        return Type.TYPE_ENUM;
    default:
        return Type.MAX_TYPE;
    }
}
struct wordmap
{
    string info;
    string token;
}
string GetType(Type field_type)
{
    string rst;
    switch(d_type(field_type))
    {
    case DType.DTYPE_INT:
        rst ~= "int";
        break;
    case DType.DTYPE_LONG:
        rst ~= "long";
        break;
    case DType.DTYPE_UINT:
        rst ~= "uint";
        break;
    case DType.DTYPE_ULONG:
        rst ~= "ulong";
        break;
    case DType.DTYPE_DOUBLE:
        rst ~= "double";
        break;
    case DType.DTYPE_FLOAT:
        rst ~= "float";
        break;
    case DType.DTYPE_BOOL:
        rst ~= "bool";
        break;
    case DType.DTYPE_STRING:
        rst ~= "string";
        break;
    case DType.DTYPE_ENUM:
    case DType.DTYPE_MESSAGE:
    case DType.MAX_DTYPE:
    default:
        break;
    }
    return rst;
}
string TypeToString(Type type)
{
    string rst;
    switch(type)
    {
    case Type.TYPE_DOUBLE:
        rst ="Type.TYPE_DOUBLE";
        break;
    case Type.TYPE_FLOAT:
        rst ="Type.TYPE_FLOAT";
        break;
    case Type.TYPE_INT64:
        rst = "Type.TYPE_INT64";
        break;
    case Type.TYPE_UINT64:
        rst = "Type.TYPE_UINT64";
        break;
    case Type.TYPE_SINT64:
        rst = "Type.TYPE_SINT64";
        break;
    case Type.TYPE_INT32:
        rst = "Type.TYPE_INT32";
        break;
    case Type.TYPE_FIXED64:
        rst = "Type.TYPE_FIXED64";
        break;
    case Type.TYPE_FIXED32:
        rst = "Type.TYPE_FIXED32";
        break;
    case Type.TYPE_BOOL:
        rst = "Type.TYPE_BOOL";
        break;
    case Type.TYPE_STRING:
        rst = "Type.TYPE_STRING";
        break;
    case Type.TYPE_BYTES:
        rst = "Type.TYPE_BYTES";
        break;
    case Type.TYPE_UINT32:
        rst = "Type.TYPE_UINT32";
        break;
    case Type.TYPE_SINT32:
        rst = "Type.TYPE_SINT32";
        break;
    case Type.TYPE_SFIXED32:
        rst = "Type.TYPE_SFIXED32";
        break;
    case Type.TYPE_SFIXED64:
        rst = "Type.TYPE_SFIXED64";
        break;
    case Type.TYPE_MESSAGE:
        rst = "Type.TYPE_MESSAGE";
        break;
    case Type.TYPE_ENUM:
        rst = "Type.TYPE_ENUM";
        break;
    default:
        throw new Exception("error type, not fixed");
    }
    return rst;
}
string TypeToFunc(Type type,bool is_pack)
{
    switch(type)
    {
    case Type.TYPE_INT64:
    case Type.TYPE_INT32:
    case Type.TYPE_UINT64:
    case Type.TYPE_UINT32:
    case Type.TYPE_SINT64:
    case Type.TYPE_SINT32:
    case Type.TYPE_ENUM:
    case Type.TYPE_BOOL:
    case Type.TYPE_SFIXED64:
    case Type.TYPE_FIXED64:
    case Type.TYPE_SFIXED32:
    case Type.TYPE_FIXED32:
    case Type.TYPE_FLOAT:
    case Type.TYPE_DOUBLE:
        if(is_pack)
            return "toPackVarint";
        return "toVarint";
    case Type.TYPE_STRING:
    case Type.TYPE_MESSAGE:
    case Type.TYPE_BYTES:
        if(is_pack)
            return "toPackByteString";
        return "toByteString";
    case Type.TYPE_GROUP:
        return "toPackGroup";
    default:
        throw new Exception("No encode func found");
    }
}
string ReadValueFunc(Type type)
{
    switch(type)
    {
    case Type.TYPE_DOUBLE:
        return "fromFixed!(double)(value)";
    case Type.TYPE_FLOAT:
        return "fromFixed!(float)(value)";
    case Type.TYPE_FIXED64:
        return "fromFixed!(ulong)(value)";
    case Type.TYPE_FIXED32:
        return "fromFixed!(uint)(value)";
    case Type.TYPE_SFIXED64:
        return "fromFixed!(long)(value)";
    case Type.TYPE_SFIXED32:
        return "fromFixed!(int)(value)";
    case Type.TYPE_INT64:
        return "cast(long)Decode!(ulong)(value)";
    case Type.TYPE_UINT64:
        return "Decode!(ulong)(value)";
    case Type.TYPE_INT32:
        return "cast(int)Decode!(uint)(value)";
    case Type.TYPE_UINT32:
    case Type.TYPE_ENUM:
        return "Decode!(uint)(value)";
    case Type.TYPE_BOOL:
        return "((Decode!(uint)(value)== 1)?true:false)";
    case Type.TYPE_STRING:
    case Type.TYPE_BYTES:
        return "cast(string)value";
    case Type.TYPE_SINT32:
        return "ZigZagDecode32(Decode!(uint)(value))";
    case Type.TYPE_SINT64:
        return "ZigZagDecode64(Decode!(ulong)(value))";
    }
}
