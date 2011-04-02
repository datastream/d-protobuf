private alias char[] string;

enum DType {
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

enum Label {
  LABEL_OPTIONAL      = 1,    // optional
  LABEL_REQUIRED      = 2,    // required
  LABEL_REPEATED      = 3,    // repeated
  MAX_LABEL           = 3,    // Constant useful for defining lookup tables indexed by Label.
}    

enum FieldType
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
enum WireType { 
  WIRETYPE_VARINT           = 0,
  WIRETYPE_FIXED64          = 1,
  WIRETYPE_LENGTH_DELIMITED = 2,
  WIRETYPE_START_GROUP      = 3,
  WIRETYPE_END_GROUP        = 4,
  WIRETYPE_FIXED32          = 5,
};
// Number of bits in a tag which identify the wire type.
static const int TagTypeBits = 3;
// Mask for those bits.
static const uint TagTypeMask = (1 << TagTypeBits) - 1;

struct wordmap
{
  string info;
  string token;
}
