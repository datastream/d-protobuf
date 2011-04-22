private import wireformatlite;
private import wireformat;
private import message;
private import prototype;
private import io;

ExtensionSet extensionset;

class ExtensionIdentifier : WireFormat
{
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, int value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      default_int32 = value;
    if(field_type == FieldType.TYPE_ENUM)
      default_enum = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, uint value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      default_uint32 = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, long value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      default_int64 = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, ulong value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      default_uint64 = value;
    extensionset = new ExtensionSet; 
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, float value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_FLOAT)
      default_float = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, double value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_DOUBLE)
      default_double = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, char[] value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_STRING)
      default_string = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, byte[] value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_BYTES)
      default_bytes = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, Message value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_MESSAGE)
      default_message = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num, bool value)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    if(field_type == FieldType.TYPE_BOOL)
      default_bool = value;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  this(char[] owner, bool repeat, bool pack, FieldType type, int num)
  {
    this.owner = owner;
    this.is_repeated = repeat;
    this.is_packed = pack;
    this.field_type = type;
    this.field_num = num;
    extensionset = new ExtensionSet;
    extensionset.AddExtension(&this);
  }
  // Set value
  // type 1
  void Set(int value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      int32_value = value;
    if(field_type == FieldType.TYPE_ENUM)
      enum_value = value;
  }
  void Set(uint value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      uint32_value = value;
  }
  void Set(long value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      int64_value = value;
  }
  void Set(ulong value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      uint64_value = value;
  }
  void Set(double value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      double_value = value;
  }
  void Set(float value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      float_value = value;
  }
  void Set(bool value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      bool_value = value;    
  }
  void Set(byte[] value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      bytes_value = value;
  }
  void Set(char[] value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      string_value = value;
  }
  void Set(Message value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      message_value = value;
  }
  //type 2
  void Set(int[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      int32_values = values;
    if(field_type == FieldType.TYPE_ENUM)
      enum_values = values;
  }
  void Set(uint[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      uint32_values = values;
  }
  void Set(long[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      int64_values = values;
  }
  void Set(ulong[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      uint64_values = values;
  }
  void Set(double[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      double_values = values;
  }
  void Set(float[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      float_values = values;
  }
  void Set(bool[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      bool_values = values;    
  }
  void Set(byte[][] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      bytes_values = values;
  }
  void Set(char[][] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      string_values = values;
  }
  void Set(Message[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      message_values = values;
  }
  //type 3
  void Set(int value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      if(int32_values.length < index)
        int32_values[index] = value;
    if(field_type == FieldType.TYPE_ENUM)
      if(enum_values.length < index)
        enum_values[index] = value;
  }
  void Set(uint value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      if(uint32_values.length < index)
        uint32_values[index] = value;
  }
  void Set(long value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      if(int64_values.length < index)
        int64_values[index] = value;
  }
  void Set(ulong value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      if(uint64_values.length < index)
        uint64_values[index] = value;
  }
  void Set(double value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      if(double_values.length < index)
        double_values[index] = value;
  }
  void Set(float value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      if(float_values.length < index)
        float_values[index] = value;
  }
  void Set(bool value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      if(bool_values.length < index)
        bool_values[index] = value;    
  }
  void Set(byte[] value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      if(bytes_values.length < index)
        bytes_values[index] = value;
  }
  void Set(char[] value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      if(string_values.length < index)
        string_values[index] = value;
  }
  void Set(Message value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      if(message_values.length < index)
        message_values[index] = value;
  }
  //Add
  void Add(int value)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      int32_values ~= value;
    if(field_type == FieldType.TYPE_ENUM)
      enum_values ~= value;
  }
  void Add(uint value)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      uint32_values ~= value;
  }
  void Add(long value)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      int64_values ~= value;
  }
  void Add(ulong value)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      uint64_values ~= value;
  }
  void Add(double value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      double_values ~= value;
  }
  void Add(float value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      float_values ~= value;
  }
  void Add(bool value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      bool_values ~= value;    
  }
  void Add(byte[] value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      bytes_values ~= value;
  }
  void Add(char[] value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      string_values ~= value;
  }
  void Add(Message value)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      message_values ~= value;
  }
  //Get Value
  //type 1
  void Get(out int value)
  {
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      value = int32_value;
    if(field_type == FieldType.TYPE_ENUM)
      value = enum_value;
  }
  void Get(out uint value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      value = uint32_value;
  }
  void Get(out long value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      value = int64_value;
  }
  void Get(out ulong value)
  {
    if(is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      value = uint64_value;
  }
  void Get(out double value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      value = double_value;
  }
  void Get(out float value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      value = float_value;
  }
  void Get(out bool value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      value = bool_value;
  }
  void Get(out byte[] value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      value = bytes_value;
  }
  void Get(out char[] value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      value = string_value;
  }
  void Get(out Message value)
  {
    if(is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      value = message_value;
  }
  //type 2
  void Get(out int[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      values =  int32_values;
    if(field_type == FieldType.TYPE_ENUM)
      values =  enum_values;
  }
  void Get(out uint[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      values =  uint32_values;
  }
  void Get(out long[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      values =  int64_values;
  }
  void Get(out ulong[] values)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      values =  uint64_values;
  }
  void Get(out double[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      values =  double_values;
  }
  void Get(out float[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      values =  float_values;
  }
  void Get(out bool[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      values =  bool_values;
  }
  void Get(out byte[][] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      values =  bytes_values;
  }
  void Get(out char[][] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      values =  string_values;
  }
  void Get(out Message[] values)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      values =  message_values;
  }
  //type 3
  void Get(out int value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT32)||(field_type == FieldType.TYPE_SFIXED32)||(field_type == FieldType.TYPE_SINT32))
      value = int32_value;
    if(field_type == FieldType.TYPE_ENUM)
      value = enum_value;
  }
  void Get(out uint value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT32)||(field_type == FieldType.TYPE_FIXED32))
      value = uint32_values[index];
  }
  void Get(out long value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_INT64)||(field_type == FieldType.TYPE_SFIXED64)||(field_type == FieldType.TYPE_SINT64))
      value = int64_values[index];
  }
  void Get(out ulong value, int index)
  {
    if(!is_repeated) return;
    if((field_type == FieldType.TYPE_UINT64)||(field_type == FieldType.TYPE_FIXED64))
      value = uint64_values[index];
  }
  void Get(out double value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_DOUBLE)
      value = double_values[index];
  }
  void Get(out float value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_FLOAT)
      value = float_values[index];
  }
  void Get(out bool value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BOOL)
      value = bool_values[index];
  }
  void Get(out byte[] value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_BYTES)
      value = bytes_values[index];
  }
  void Get(out char[] value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_STRING)
      value = string_values[index];
  }
  void Get(out Message value, int index)
  {
    if(!is_repeated) return;
    if(field_type == FieldType.TYPE_MESSAGE)
      value = message_values[index];
  }
  void Serialize(ref CodedOutputStream output)
  {
    switch(field_type)
    {
      case FieldType.TYPE_INT32:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < int32_values.length ;i ++) {
              len += Int32Size(int32_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int32_values.length; i++) {
              WriteInt32NoTag(int32_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int32_values.length; i++) {
              WriteInt32(field_num, int32_values[i], output);
            }
          } else {
            WriteInt32(field_num, int32_value, output);
          }
          break;
        }
      case FieldType.TYPE_UINT32:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < uint32_values.length ; i++) {
              len += UInt32Size(uint32_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < uint32_values.length; i++) {
              WriteUInt32NoTag(uint32_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < uint32_values.length; i++) {
              WriteUInt32(field_num, uint32_values[i], output);
            }
          } else {
            WriteUInt32(field_num, uint32_value, output);
          }
          break;
        }
      case FieldType.TYPE_SINT32:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < int32_values.length ; i++) {
              len += SInt32Size(int32_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int32_values.length; i++) {
              WriteSInt32NoTag(int32_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int32_values.length; i++) {
              WriteSInt32(field_num, int32_values[i], output);
            }
          } else {
            WriteSInt32(field_num, int32_value, output);
          }
          break;
        }
      case FieldType.TYPE_FIXED32:
        {
          if(is_packed) {
            int len;
            len += uint32_values.length * uint32_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < uint32_values.length; i++) {
              WriteFixed32NoTag(uint32_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < uint32_values.length; i++) {
              WriteFixed32(field_num, uint32_values[i], output);
            }
          } else {
            WriteFixed32(field_num, uint32_value, output);
          }
          break;
        }
      case FieldType.TYPE_SFIXED32:
        {
          if(is_packed) {
            int len;
            len += int32_values.length * int32_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int32_values.length; i++) {
              WriteSFixed32NoTag(int32_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int32_values.length; i++) {
              WriteSFixed32(field_num, int32_values[i], output);
            }
          } else {
            WriteSFixed32(field_num, int32_value, output);
          }
          break;
        }
      case FieldType.TYPE_INT64:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < int64_values.length ; i++) {
              len += Int64Size(int64_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int64_values.length; i++) {
              WriteInt64NoTag(int64_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int64_values.length; i++) {
              WriteInt64(field_num, int64_values[i], output);
            }
          } else {
            WriteInt64(field_num, int64_value, output);
          }
          break;
        }
      case FieldType.TYPE_UINT64:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < uint64_values.length ; i++) {
              len += UInt64Size(uint64_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < uint64_values.length; i++) {
              WriteUInt64NoTag(uint64_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < uint64_values.length; i++) {
              WriteUInt64(field_num, uint64_values[i], output);
            }
          } else {
            WriteUInt64(field_num, uint64_value, output);
          }
          break;
        }
      case FieldType.TYPE_SINT64:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < int64_values.length; i++) {
              len += SInt64Size(int64_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int64_values.length; i++) {
              WriteSInt64NoTag(int64_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int32_values.length; i++) {
              WriteSInt64(field_num, int64_values[i], output);
            }
          } else {
            WriteSInt64(field_num, int64_value, output);
          }
          break;
        }
      case FieldType.TYPE_FIXED64:
        {
          if(is_packed) {
            int len;
            len += uint64_values.length * uint64_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < uint64_values.length; i++) {
              WriteFixed64NoTag(uint64_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < uint64_values.length; i++) {
              WriteFixed64(field_num, uint64_values[i], output);
            }
          } else {
            WriteFixed64(field_num, uint64_value, output);
          }
          break;
        }
      case FieldType.TYPE_SFIXED64:
        {
          if(is_packed) {
            int len;
            len += int64_values.length * int64_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < int64_values.length; i++) {
              WriteSFixed64NoTag(int64_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < int64_values.length; i++) {
              WriteSFixed64(field_num, int64_values[i], output);
            }
          } else {
            WriteSFixed64(field_num, int64_value, output);
          }
          break;
        }
      case FieldType.TYPE_DOUBLE:
        {
          if(is_packed) {
            int len;
            len += double_values.length * double_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < double_values.length; i++) {
              WriteDoubleNoTag(double_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < double_values.length; i++) {
              WriteDouble(field_num, double_values[i], output);
            }
          } else {
            WriteDouble(field_num, double_value, output);
          }
          break;
        }
      case FieldType.TYPE_FLOAT:
        {
          if(is_packed) {
            int len;
            len += float_values.length*float_values[0].sizeof;
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < float_values.length; i++) {
              WriteFloatNoTag(float_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < float_values.length; i++) {
              WriteFloat(field_num, float_values[i], output);
            }
          } else {
            WriteFloat(field_num, float_value, output);
          }
          break;
        }
      case FieldType.TYPE_ENUM:
        {
          if(is_packed) {
            int len;
            for(int i = 0; i < enum_values.length ;i ++) {
              len += Int32Size(enum_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < enum_values.length; i++) {
              WriteInt32NoTag(enum_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < enum_values.length; i++) {
              WriteInt32(field_num, enum_values[i], output);
            }
          } else {
            WriteInt32(field_num, enum_value, output);
          }
          break;
        }
      case FieldType.TYPE_BOOL:
        {
          if(is_packed) {
            uint len;
            for(int i = 0; i < bool_values.length ;i ++) {
              len += UInt32Size(bool_values[i]?1:0);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < bool_values.length; i++) {
              WriteBoolNoTag(bool_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < bool_values.length; i++) {
              WriteBool(field_num, bool_values[i], output);
            }
          } else {
            WriteBool(field_num, bool_value, output);
          }
          break;
        }
      case FieldType.TYPE_BYTES:
        {
          if(is_packed) {
            uint len;
            for(int i = 0; i < bytes_values.length ;i ++) {
              len += BytesSize(cast(char[])bytes_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < bytes_values.length; i++) {
              WriteBytesNoTag(bytes_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < bytes_values.length; i++) {
              WriteBytes(field_num, bytes_values[i], output);
            }
          } else {
            WriteBytes(field_num, bytes_value, output);
          }
          break;
        }
      case FieldType.TYPE_STRING:
        {
          if(is_packed) {
            uint len;
            for(int i = 0; i < string_values.length ;i ++) {
              len += StringSize(string_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < string_values.length; i++) {
              WriteStringNoTag(string_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < string_values.length; i++) {
              WriteString(field_num, string_values[i], output);
            }
          } else {
            WriteString(field_num, string_value, output);
          }
          break;
        }
      case FieldType.TYPE_MESSAGE:
        {
          if(is_packed) {
            uint len;
            for(int i = 0; i < message_values.length ;i ++) {
              len += MessageSize(message_values[i]);
            }
            WriteTag(field_num, WireType.WIRETYPE_LENGTH_DELIMITED, output);
            output.WriteVarint32(len);
            for(int i = 0; i < message_values.length; i++) {
              WriteMessageNoTag(message_values[i], output);
            }
          } else if(is_repeated) {
            for(int i = 0; i < message_values.length; i++) {
              WriteMessage(field_num, message_values[i], output);
            }
          } else {
            WriteMessage(field_num, message_value, output);
          }
          break;
        }
    }
  }
  void MergePartialFromStream(ref CodedInputStream input)
  {
    uint tag = input.ReadTag();
    if((GetTagFieldNumber(tag) == field_num) && (GetTagWireType(tag)))
    {
      switch(field_type)
      {
        case FieldType.TYPE_INT32:
          {
            if(is_packed) {
              ReadPackedPrimitive!(int)(UInt32Size(tag), tag, input, int32_values, FieldType.TYPE_INT32);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(int)(input, int32_values, FieldType.TYPE_INT32);
            } else {
              ReadPrimitive!(int)(input, int32_value, FieldType.TYPE_INT32);
            }
            break;
          }
        case FieldType.TYPE_UINT32:
          {
            if(is_packed) {
              ReadPackedPrimitive!(uint)(UInt32Size(tag), tag, input, uint32_values, FieldType.TYPE_UINT32);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(uint)(input, uint32_values, FieldType.TYPE_UINT32);
            } else {
              ReadPrimitive!(uint)(input, uint32_value, FieldType.TYPE_UINT32);
            }
            break;
          }
        case FieldType.TYPE_SINT32:
          {
            if(is_packed) {
              ReadPackedPrimitive!(int)(UInt32Size(tag), tag, input, int32_values, FieldType.TYPE_SINT32);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(int)(input, int32_values, FieldType.TYPE_SINT32);
            } else {
              ReadPrimitive!(int)(input, int32_value, FieldType.TYPE_SINT32);
            }
            break;
          }
        case FieldType.TYPE_FIXED32:
          {
            if(is_packed) {
              ReadPackedPrimitive!(uint)(UInt32Size(tag), tag, input, uint32_values, FieldType.TYPE_FIXED32);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(uint)(input, uint32_values, FieldType.TYPE_FIXED32);
            } else {
              ReadPrimitive!(uint)(input, uint32_value, FieldType.TYPE_FIXED32);
            }
            break;
          }
        case FieldType.TYPE_SFIXED32:
          {
            if(is_packed) {
              ReadPackedPrimitive!(int)(UInt32Size(tag), tag, input, int32_values, FieldType.TYPE_SFIXED32);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(int)(input, int32_values, FieldType.TYPE_SFIXED32);
            } else {
              ReadPrimitive!(int)(input, int32_value, FieldType.TYPE_SFIXED32);
            }
            break;
          }
        case FieldType.TYPE_INT64:
          {
            if(is_packed) {
              ReadPackedPrimitive!(long)(UInt32Size(tag), tag, input, int64_values, FieldType.TYPE_INT64);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(long)(input, int64_values, FieldType.TYPE_INT64);
            } else {
              ReadPrimitive!(long)(input, int64_value, FieldType.TYPE_INT64);
            }
            break;
          }
        case FieldType.TYPE_UINT64:
          {
            if(is_packed) {
              ReadPackedPrimitive!(ulong)(UInt32Size(tag), tag, input, uint64_values, FieldType.TYPE_UINT64);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(ulong)(input, uint64_values, FieldType.TYPE_UINT64);
            } else {
              ReadPrimitive!(ulong)(input, uint64_value, FieldType.TYPE_UINT64);
            }
            break;
          }
        case FieldType.TYPE_SINT64:
          {
            if(is_packed) {
              ReadPackedPrimitive!(long)(UInt32Size(tag), tag, input, int64_values, FieldType.TYPE_SINT64);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(long)(input, int64_values, FieldType.TYPE_SINT64);
            } else {
              ReadPrimitive!(long)(input, int64_value, FieldType.TYPE_SINT64);
            }
            break;
          }
        case FieldType.TYPE_FIXED64:
          {
            if(is_packed) {
              ReadPackedPrimitive!(ulong)(UInt32Size(tag), tag, input, uint64_values, FieldType.TYPE_FIXED64);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(ulong)(input, uint64_values, FieldType.TYPE_FIXED64);
            } else {
              ReadPrimitive!(ulong)(input, uint64_value, FieldType.TYPE_FIXED64);
            }
            break;
          }
        case FieldType.TYPE_SFIXED64:
          {
            if(is_packed) {
              ReadPackedPrimitive!(long)(UInt32Size(tag), tag, input, int64_values, FieldType.TYPE_SFIXED64);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(long)(input, int64_values, FieldType.TYPE_SFIXED64);
            } else {
              ReadPrimitive!(long)(input, int64_value, FieldType.TYPE_SFIXED64);
            }
            break;
          }
        case FieldType.TYPE_DOUBLE:
          {
            if(is_packed) {
              ReadPackedPrimitive!(double)(UInt32Size(tag), tag, input, double_values, FieldType.TYPE_DOUBLE);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(double)(input, double_values, FieldType.TYPE_DOUBLE);
            } else {
              ReadPrimitive!(double)(input, double_value, FieldType.TYPE_DOUBLE);
            }
            break;
          }
        case FieldType.TYPE_FLOAT:
          {
            if(is_packed) {
              ReadPackedPrimitive!(float)(UInt32Size(tag), tag, input, float_values, FieldType.TYPE_FLOAT);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(float)(input, float_values, FieldType.TYPE_FLOAT);
            } else {
              ReadPrimitive!(float)(input, float_value, FieldType.TYPE_FLOAT);
            }
            break;
          }
        case FieldType.TYPE_BOOL:
          {
            if(is_packed) {
              ReadPackedPrimitive!(bool)(UInt32Size(tag), tag, input, bool_values, FieldType.TYPE_BOOL);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(bool)(input, bool_values, FieldType.TYPE_BOOL);
            } else {
              ReadPrimitive!(bool)(input, bool_value, FieldType.TYPE_BOOL);
            }
            break;
          }
        case FieldType.TYPE_ENUM:
          {
            if(is_packed) {
              ReadPackedPrimitive!(int)(UInt32Size(tag), tag, input, enum_values, FieldType.TYPE_ENUM);
            } else if(is_repeated) {
              ReadRepeatedPrimitive!(int)(input, enum_values, FieldType.TYPE_ENUM);
            } else {
              ReadPrimitive!(int)(input, enum_value, FieldType.TYPE_ENUM);
            }
            break;
          }
        case FieldType.TYPE_BYTES:
          {
            if(is_packed) {
              ReadPackedBytes(input, bytes_values, FieldType.TYPE_BYTES);
            } else if(is_repeated) {
              ReadRepeatedBytes(input, bytes_values, FieldType.TYPE_BYTES);
            } else {
              ReadBytes(input, bytes_value, FieldType.TYPE_BYTES);
            }
            break;
          }
        case FieldType.TYPE_STRING:
          {
            if(is_packed) {
              ReadPackedString(input, string_values, FieldType.TYPE_STRING);
            } else if(is_repeated) {
              ReadRepeatedString(input, string_values, FieldType.TYPE_STRING);
            } else {
              ReadString(input, string_value, FieldType.TYPE_STRING);
            }
            break;
          }
        case FieldType.TYPE_MESSAGE:
          {
            if(is_packed) {
              ReadPackedMessageNoVirtual(input, message_values, FieldType.TYPE_MESSAGE);
            } else if(is_repeated) {
              ReadRepeatedMessageNoVirtual(input, message_values, FieldType.TYPE_MESSAGE);
            } else {
              ReadMessageNoVirtual(input, message_value, FieldType.TYPE_MESSAGE);
            }
            break;
          }
      }
    }
  }
private:
  char[] owner;
  bool is_repeated;
  bool is_packed;
  FieldType field_type;
  int field_num;
  union {
    int default_int32;
    uint default_uint32;
    long default_int64;
    ulong default_uint64;
    float default_float;
    double default_double;
    bool default_bool;
    int default_enum;
    char[] default_string;
    byte[] default_bytes;
    Message default_message;
  };
  union {
    int int32_value;
    uint uint32_value;
    long int64_value;
    ulong uint64_value;
    float float_value;
    double double_value;
    bool bool_value;
    int enum_value;
    char[] string_value;
    byte[] bytes_value;
    Message message_value;
    int[] int32_values;
    uint[] uint32_values;
    long[] int64_values;
    ulong[] uint64_values;
    bool[] bool_values;
    int[] enum_values;
    float[] float_values;
    double[] double_values;
    char[][] string_values;
    byte[][] bytes_values;
    Message[] message_values;    
  }
}
class ExtensionSet
{
  ExtensionIdentifier* Find(ExtensionIdentifier extid)
  {
    for(int i = 0; i < exts.length; i++)
    {
      if((extid.owner == exts[i].owner) && (extid.field_num == exts[i].field_num))
        return exts[i];
    }
  }
  ExtensionIdentifier*[] IsClass(Message containing_type)
  {
    ExtensionIdentifier*[] rst;
    for(int i = 0; i < exts.length; i++)
    {
      if((containing_type.classinfo.name == exts[i].owner))
        rst ~= exts[i];
    }
    return rst;
  }
  bool HasExtension(ExtensionIdentifier* extid)
  {
    for(int i = 0; i < exts.length; i++)
    {
      if((extid.owner == exts[i].owner) && (extid.field_num == exts[i].field_num))
        return true;
    }
    return false;
  }
  void AddExtension(ExtensionIdentifier* extid)
  {
    if(!HasExtension(extid))
    {
      exts ~= extid;
    }
  }
 private:
  static ExtensionIdentifier*[] exts;
}
template Ext()
{
  //Set
  //type 1
  void SetExtension(ref ExtensionIdentifier extid, int value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, uint value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, long value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, ulong value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, double value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, float value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, byte[] value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, char[] value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, Message value)
  {
    extensionset.Find(extid).Set(value);
  }
  void SetExtension(ref ExtensionIdentifier extid, bool value)
  {
    extensionset.Find(extid).Set(value);
  }
  //type 2
  void SetExtension(ref ExtensionIdentifier extid, int[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, uint[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, long[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, ulong[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, double[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, float[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, byte[][] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, char[][] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, Message[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  void SetExtension(ref ExtensionIdentifier extid, bool[] values)
  {
    extensionset.Find(extid).Set(values);
  }
  //type 3
  void SetExtension(ref ExtensionIdentifier extid, int index, int value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, uint value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, long value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, ulong value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, double value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, float value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, byte[] value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, char[] value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, Message value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  void SetExtension(ref ExtensionIdentifier extid, int index, bool value)
  {
    extensionset.Find(extid).Set(value, index);
  }
  // Add
  void AddValue(ref ExtensionIdentifier extid, int value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, uint value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, long value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, ulong value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, double value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, float value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, byte[] value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, char[] value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, Message value)
  {
    extensionset.Find(extid).Add(value);
  }
  void AddValue(ref ExtensionIdentifier extid, bool value)
  {
    extensionset.Find(extid).Add(value);
  }
  // Get
  // type 1
  int GetExtension(ref ExtensionIdentifier extid)
  {
    int value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  uint GetExtension(ref ExtensionIdentifier extid)
  {
    uint value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  long GetExtension(ref ExtensionIdentifier extid)
  {
    long value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  ulong GetExtension(ref ExtensionIdentifier extid)
  {
    ulong value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  double GetExtension(ref ExtensionIdentifier extid)
  {
    double value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  float GetExtension(ref ExtensionIdentifier extid)
  {
    float value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  byte[] GetExtension(ref ExtensionIdentifier extid)
  {
    byte[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  char[] GetExtension(ref ExtensionIdentifier extid)
  {
    char[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  bool GetExtension(ref ExtensionIdentifier extid)
  {
    bool value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  Message GetExtension(ref ExtensionIdentifier extid)
  {
    Message value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  //type 2
  int[] GetExtension(ref ExtensionIdentifier extid)
  {
    int[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  uint[] GetExtension(ref ExtensionIdentifier extid)
  {
    uint[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  long[] GetExtension(ref ExtensionIdentifier extid)
  {
    long[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  ulong[] GetExtension(ref ExtensionIdentifier extid)
  {
    ulong[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  double[] GetExtension(ref ExtensionIdentifier extid)
  {
    double[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  float[] GetExtension(ref ExtensionIdentifier extid)
  {
    float[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  byte[][] GetExtension(ref ExtensionIdentifier extid)
  {
    byte[][] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  char[][] GetExtension(ref ExtensionIdentifier extid)
  {
    char[][] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  bool[] GetExtension(ref ExtensionIdentifier extid)
  {
    bool[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  Message[] GetExtension(ref ExtensionIdentifier extid)
  {
    Message[] value;
    extensionset.Find(extid).Get(value);
    return value;
  }
  //type 3
  int GetExtension(ref ExtensionIdentifier extid, int index)
  {
    int value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  uint GetExtension(ref ExtensionIdentifier extid, int index)
  {
    uint value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  long GetExtension(ref ExtensionIdentifier extid, int index)
  {
    long value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  ulong GetExtension(ref ExtensionIdentifier extid, int index)
  {
    ulong value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  double GetExtension(ref ExtensionIdentifier extid, int index)
  {
    double value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  float GetExtension(ref ExtensionIdentifier extid, int index)
  {
    float value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  byte[] GetExtension(ref ExtensionIdentifier extid, int index)
  {
    byte[] value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  char[] GetExtension(ref ExtensionIdentifier extid, int index)
  {
    char[] value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  bool GetExtension(ref ExtensionIdentifier extid, int index)
  {
    bool value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  Message GetExtension(ref ExtensionIdentifier extid, int index)
  {
    Message value;
    extensionset.Find(extid).Get(value, index);
    return value;
  }
  void SerializeExtension(ref CodedOutputStream output)
  {
    ExtensionIdentifier*[] elements = extensionset.IsClass(this);
    for(int i = 0; i < elements.length; i++)
    {
      elements[i].Serialize(output);
    }
  }
}
/*  
  void ExtensionMergePartialFromStream(ref CodedInputStream input)
  {
    ExtensionIdentifier*[] elements = extensionset.isClass(this);
    for(int i = 0; i < elements.length; i++)
    {
      elements[i].Serialize(output);
    }
  }
*/
