private import prototype;

WireType GetWireTypeForFieldType(FieldType tname)
{
  switch(tname)
  {
    case FieldType.TYPE_INT64:
    case FieldType.TYPE_INT32:
    case FieldType.TYPE_UINT64:
    case FieldType.TYPE_UINT32:
    case FieldType.TYPE_SINT64:
    case FieldType.TYPE_SINT32:
    case FieldType.TYPE_ENUM:
    case FieldType.TYPE_BOOL:
      return WireType.WIRETYPE_VARINT;
      break;
    case FieldType.TYPE_SFIXED64:
    case FieldType.TYPE_FIXED64:
    case FieldType.TYPE_DOUBLE:
      return WireType.WIRETYPE_FIXED64;
      break;
    case FieldType.TYPE_SFIXED32:
    case FieldType.TYPE_FIXED32:
    case FieldType.TYPE_FLOAT:
      return  WireType.WIRETYPE_FIXED32;
      break;
    case FieldType.TYPE_STRING:
    case FieldType.TYPE_MESSAGE:
    case FieldType.TYPE_BYTES:
      return  WireType.WIRETYPE_LENGTH_DELIMITED;
      break;
    case FieldType.TYPE_GROUP:
      return WireType.WIRETYPE_START_GROUP;
      break;
  }
}
DType d_type(FieldType field_type)
{
  switch(field_type)
  {
    case FieldType.TYPE_DOUBLE:
      return DType.DTYPE_DOUBLE;
    case FieldType.TYPE_FLOAT:
      return DType.DTYPE_FLOAT;
    case FieldType.TYPE_UINT32:
    case FieldType.TYPE_FIXED32:
      return DType.DTYPE_UINT;
    case FieldType.TYPE_INT32:
    case FieldType.TYPE_SINT32:
    case FieldType.TYPE_SFIXED32:
      return DType.DTYPE_INT;
    case FieldType.TYPE_UINT64:
    case FieldType.TYPE_FIXED64:
      return DType.DTYPE_ULONG;
    case FieldType.TYPE_INT64:
    case FieldType.TYPE_SINT64:
    case FieldType.TYPE_SFIXED64:
      return DType.DTYPE_LONG;
    case FieldType.TYPE_BYTES:
    case FieldType.TYPE_STRING:
      return DType.DTYPE_STRING;
    case FieldType.TYPE_BOOL:
      return DType.DTYPE_BOOL;
    case FieldType.TYPE_ENUM:
      return DType.DTYPE_ENUM;
    case FieldType.TYPE_MESSAGE:
    case FieldType.TYPE_GROUP:
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
FieldType StringToFieldType(string type)
{
  switch(type)
  {
    case "double":
      return FieldType.TYPE_DOUBLE;
    case "float":
      return FieldType.TYPE_FLOAT;
    case "int64":
      return FieldType.TYPE_INT64;
    case "uint64":
      return FieldType.TYPE_UINT64;
    case "sint64":
      return FieldType.TYPE_SINT64;
    case "fixed64":
      return FieldType.TYPE_FIXED64;
    case "sfixed64":
      return FieldType.TYPE_SFIXED64;
    case "int32":
      return FieldType.TYPE_INT32;
    case "uint32":
      return FieldType.TYPE_UINT32;
    case "sint32":
      return FieldType.TYPE_SINT32;
    case "fixed32":
      return FieldType.TYPE_FIXED32;
    case "sfixed32":
      return FieldType.TYPE_SFIXED32;
    case "bool":
      return FieldType.TYPE_BOOL;
    case "string":
      return FieldType.TYPE_STRING;
    case "bytes":
      return FieldType.TYPE_BYTES;
    case "message":
      return FieldType.TYPE_MESSAGE;
    case "enum":
      return FieldType.TYPE_ENUM;
    default:
      return FieldType.MAX_TYPE;
  }
}
string GetDTypeToString(FieldType field_type)
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
      rst ~= "char[]";
      break;
    case DType.DTYPE_ENUM:
    case DType.DTYPE_MESSAGE:
    case DType.MAX_DTYPE:
    default:
      break;
  }
  return rst;
}
string FieldTypeToString(FieldType type)
{
  string rst;
  switch(type)
  {
    case FieldType.TYPE_DOUBLE:
      rst ="FieldType.TYPE_DOUBLE";
      break;
    case FieldType.TYPE_FLOAT:
      rst ="FieldType.TYPE_FLOAT";
      break;
    case FieldType.TYPE_INT64:
      rst = "FieldType.TYPE_INT64";
      break;
    case FieldType.TYPE_UINT64:
      rst = "FieldType.TYPE_UINT64";
      break;
    case FieldType.TYPE_SINT64:
      rst = "FieldType.TYPE_SINT64";
      break;
    case FieldType.TYPE_INT32:
      rst = "FieldType.TYPE_INT32";
      break;
    case FieldType.TYPE_FIXED64:
      rst = "FieldType.TYPE_FIXED64";
      break;
    case FieldType.TYPE_FIXED32:
      rst = "FieldType.TYPE_FIXED32";
      break;
    case FieldType.TYPE_BOOL:
      rst = "FieldType.TYPE_BOOL";
      break;
    case FieldType.TYPE_STRING:
      rst = "FieldType.TYPE_STRING";
      break;
    case FieldType.TYPE_BYTES:
      rst = "FieldType.TYPE_BYTES";
      break;
    case FieldType.TYPE_UINT32:
      rst = "FieldType.TYPE_UINT32";
      break;
    case FieldType.TYPE_SINT32:
      rst = "FieldType.TYPE_SINT32";
      break;
    case FieldType.TYPE_SFIXED32:
      rst = "FieldType.TYPE_SFIXED32";
      break;
    case FieldType.TYPE_SFIXED64:
      rst = "FieldType.TYPE_SFIXED64";
      break;
    case FieldType.TYPE_MESSAGE:
      rst = "FieldType.TYPE_MESSAGE";
      break;
    case FieldType.TYPE_ENUM:
      rst = "FieldType.TYPE_ENUM";
      break;
    default:
      throw new Exception("error type, not fixed");
  }
  return rst;
}
string FieldTypeToFunc(FieldType type)
{
  switch(type)
  {
    case FieldType.TYPE_INT64:
      return "WriteInt64";
    case FieldType.TYPE_INT32:
      return "WriteInt32";
    case FieldType.TYPE_UINT64:
      return "WriteUInt64";
    case FieldType.TYPE_UINT32:
      return "WriteUInt32";
    case FieldType.TYPE_SINT64:
      return "WriteSInt32";
    case FieldType.TYPE_SINT32:
      return "WriteSInt64";
    case FieldType.TYPE_ENUM:
      return "WriteEnum";
    case FieldType.TYPE_BOOL:
      return "WriteBool";
    case FieldType.TYPE_SFIXED64:
      return "WriteSFixed64";
    case FieldType.TYPE_FIXED64:
      return "WriteFixed64";
    case FieldType.TYPE_SFIXED32:
      return "WriteSFixed32";
    case FieldType.TYPE_FIXED32:
      return "WriteFixed32";
    case FieldType.TYPE_FLOAT:
      return "WriteFloat";
    case FieldType.TYPE_DOUBLE:
      return "WriteDouble";
    case FieldType.TYPE_STRING:
      return "WriteString";
    case FieldType.TYPE_MESSAGE:
      return "WriteMessageNoVirtual";
    case FieldType.TYPE_BYTES:
      return "WriteBytes";
    case FieldType.TYPE_GROUP:
      return "WriteGroupNoVirtual";
    default:
      throw new Exception("No encode func found");
  }
}
string genGetSizeFunc(FieldType type)
{
  switch(type)
  {
    case FieldType.TYPE_INT64:
      return "Int64Size";
    case FieldType.TYPE_INT32:
      return "Int32Size";
    case FieldType.TYPE_UINT64:
      return "UInt64Size";
    case FieldType.TYPE_UINT32:
      return "UInt32Size";
    case FieldType.TYPE_SINT64:
      return "SInt32Size";
    case FieldType.TYPE_SINT32:
      return "SInt64Size";
    case FieldType.TYPE_ENUM:
      return "EnumSize";
    case FieldType.TYPE_BOOL:
      return "BoolSize";
    case FieldType.TYPE_SFIXED64:
      return null;
    case FieldType.TYPE_FIXED64:
      return null;
    case FieldType.TYPE_SFIXED32:
      return null;
    case FieldType.TYPE_FIXED32:
      return null;
    case FieldType.TYPE_FLOAT:
      return null;
    case FieldType.TYPE_DOUBLE:
      return null;
    case FieldType.TYPE_STRING:
      return "StringSize";
    case FieldType.TYPE_MESSAGE:
      return "MessageSize";
    case FieldType.TYPE_BYTES:
      return "BytesSize";
    case FieldType.TYPE_GROUP:
      return "GroupSize";
    default:
      throw new Exception("No encode func found");
  }
}
string FieldTypeToWireTypeString(FieldType type)
{
  switch(type)
  {
    case FieldType.TYPE_INT64:
    case FieldType.TYPE_INT32:
    case FieldType.TYPE_UINT64:
    case FieldType.TYPE_UINT32:
    case FieldType.TYPE_SINT64:
    case FieldType.TYPE_SINT32:
    case FieldType.TYPE_ENUM:
    case FieldType.TYPE_BOOL:
      return "WireType.WIRETYPE_VARINT";
    case FieldType.TYPE_DOUBLE:
    case FieldType.TYPE_SFIXED64:
    case FieldType.TYPE_FIXED64:
      return "WireType.WIRETYPE_FIXED64";
    case FieldType.TYPE_FLOAT:
    case FieldType.TYPE_SFIXED32:
    case FieldType.TYPE_FIXED32:
      return "WireType.WIRETYPE_FIXED32";
    case FieldType.TYPE_STRING:
    case FieldType.TYPE_MESSAGE:
    case FieldType.TYPE_BYTES:
      return "WireType.WIRETYPE_LENGTH_DELIMITED";
    case FieldType.TYPE_GROUP:
      return "WireType.WIRETYPE_START_GROUP";
    default:
      throw new Exception("No encode func found");
  }
}
string FieldTypeToReadFunc(FieldType type, bool is_repeated = false, bool is_packed = false )
{
  switch(type)
  {
    case FieldType.TYPE_INT64:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(long)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(long)";
        }
        return "ReadPrimitive!(long)";
      }
    case FieldType.TYPE_INT32:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_UINT64:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(ulong)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(ulong)";
        }
        return "ReadPrimitive!(ulong)";
      }
    case FieldType.TYPE_UINT32:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(uint)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(uint)";
        }
        return "ReadPrimitive!(uint)";
      }
    case FieldType.TYPE_SINT64:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(long)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(long)";
        }
        return "ReadPrimitive!(long)";
      }
    case FieldType.TYPE_SINT32:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_ENUM:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_BOOL:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_DOUBLE:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(double)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(double)";
        }
        return "ReadPrimitive!(double)";
      }
    case FieldType.TYPE_SFIXED64:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(long)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(long)";
        }
        return "ReadPrimitive!(long)";
      }
    case FieldType.TYPE_FIXED64:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(long)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(long)";
        }
        return "ReadPrimitive!(long)";
      }
    case FieldType.TYPE_FLOAT:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(float)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(float)";
        }
        return "ReadPrimitive!(float)";
      }
    case FieldType.TYPE_SFIXED32:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_FIXED32:
      {
        if(is_packed) {
          return "ReadPackedPrimitive!(int)";
        }
        if(is_repeated) {
          return "ReadRepeatedPrimitive!(int)";
        }
        return "ReadPrimitive!(int)";
      }
    case FieldType.TYPE_STRING:
      {
        if(is_packed) {
          return "ReadPackedString";
        }
        if(is_repeated) {
          return "ReadRepeatedString";
        }
        return "ReadString";
      }
    case FieldType.TYPE_MESSAGE:
      {
        if(is_packed) {
          return "ReadPackedMessage";
        }
        if(is_repeated) {
          return "ReadRepeatedMessage";
        }
        return "ReadMessage";
      }
    case FieldType.TYPE_BYTES:
      {
        if(is_packed) {
          return "ReadPackedBytes";
        }
        if(is_repeated) {
          return "ReadRepeatedBytes";
        }
        return "ReadBytes";
      }
    case FieldType.TYPE_GROUP:
      {
        if(is_packed) {
          return "ReadPackedGroup";
        }
        if(is_repeated) {
          return "ReadRepeatedGroup";
        }
        return "ReadGroup";
      }
    default:
      throw new Exception("No encode func found");
  }
}
